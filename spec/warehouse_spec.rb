require 'spec_helper'
require 'ostruct'

RSpec.describe Warehouse do
  before(:all) do
    class Model
      def new_record?; end

      def persisted?
        !new_record?
      end

      def destroy
        self
      end

      def save(*_args, &_block)
        true
      end

      def self.all
        OpenStruct.new(all: true)
      end

      def self.where(options)
        OpenStruct.new(where: options)
      end
    end
  end

  subject(:repository_class) do
    Class.new do
      def custom_scope
        OpenStruct.new(custom_scope: true)
      end
    end.include(described_class)
  end

  it "delegates calls on class to instance's defined domains" do
    repository_class.warehouse :model, scope: :all
    expect(repository_class.custom_scope).to eq(repository_class.new(Model.all).custom_scope)
  end

  it 'delegates calls on instance to domain' do
    relation = class_double('Model')
    expect(Model).to receive(:all) { relation }
    expect(relation).to receive(:where).with(test: true)

    repository_class.warehouse :model, scope: :all
    repository = repository_class.query
    repository.where(test: true)
  end

  describe '.warehouse' do
    subject { repository_class }

    it 'defines repository domain with the model passed if no option is passed' do
      subject.warehouse :model
      expect(subject.instance_variable_get('@domain')).to eq(Model)
    end

    it 'defines repository domain with the model passed contextualized in the scope option' do
      subject.warehouse :model, scope: :all
      expect(subject.instance_variable_get('@domain')).to eq(Model.all)
    end
  end

  describe '.create' do
    subject { repository_class.warehouse(:model, scope: :all) }

    it 'does not create if the model is already persisted' do
      model = Model.new
      allow(model).to receive(:new_record?) { false }
      expect(model).not_to receive(:save)
      expect(subject.create(model)).to be false
    end

    it 'creates if the model is a new record' do
      model = Model.new
      allow(model).to receive(:new_record?) { true }
      expect(model).to receive(:save) { true }
      expect(subject.create(model)).to be true
    end
  end

  describe '.update' do
    subject { repository_class.warehouse(:model, scope: :all) }

    it 'does not update if the model is a new record' do
      model = Model.new
      allow(model).to receive(:new_record?) { true }
      expect(model).not_to receive(:save)
      expect(subject.update(model)).to be false
    end

    it 'updates if the model is already persisted' do
      model = Model.new
      allow(model).to receive(:new_record?) { false }
      expect(model).to receive(:save) { true }
      expect(subject.update(model)).to be true
    end
  end

  describe '.destroy' do
    subject { repository_class.warehouse(:model, scope: :all) }

    it 'destroys if the model is already persisted' do
      model = Model.new
      allow(model).to receive(:new_record?) { false }
      expect(model).to receive(:destroy) { model }
      expect(subject.destroy(model)).to eq(model)
    end

    it 'does not destroy if the model is a new record' do
      model = Model.new
      allow(model).to receive(:new_record?) { true }
      expect(model).not_to receive(:destroy)
      expect(subject.destroy(model)).to be_nil
    end
  end

  describe '.query' do
    subject { repository_class.warehouse(:model, scope: :all) }

    it 'returns a warehouse instance with configured domain' do
      query = subject.query
      expect(query).to be_kind_of(Warehouse)
      expect(query.instance_variable_get('@domain')).to eq(Model.all)
    end

    it 'returns a warehouse instance with custom domain passed as argument' do
      query = subject.query(Model.where(test: true))
      expect(query).to be_kind_of(Warehouse)
      expect(query.instance_variable_get('@domain')).to eq(Model.where(test: true))
    end
  end
end
