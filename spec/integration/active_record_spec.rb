require 'spec_helper'
require 'active_record'
require 'sqlite3'

RSpec.describe 'ActiveRecord integration' do
  before(:all) do
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

    ActiveRecord::Schema.define do
      create_table(:users, force: true) do |t|
        t.string :name
        t.datetime :last_sign_in_at
        t.datetime :confirmed_at
      end
    end

    class User < ActiveRecord::Base
      scope :alphabetically, -> { order(name: :asc) }
    end

    class UserRepository
      include Repositorish

      repositorish :user, scope: :all

      def confirmed
        where.not(confirmed_at: nil)
      end

      def last_sign_in_after(date)
        where(arel_table[:last_sign_in_at].gt(date))
      end

      def active
        confirmed.last_sign_in_after(1.week.ago).alphabetically
      end
    end
  end

  it 'creates a new user' do
    john = User.new(name: 'John')

    expect(UserRepository.create(john)).to be true
    expect(john).to be_persisted
  end

  it 'updates an existing user' do
    john = User.create(name: 'John')
    john.name = 'John Will'

    expect(UserRepository.update(john)).to be true
    expect(john.reload.name).to eq('John Will')
  end

  it 'destroy an existing user' do
    john = User.create(name: 'John')

    expect(UserRepository.destroy(john)).to eq(john)
    expect { john.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'delegates the relation methods to domain' do
    mary = User.create(name: 'Mary', last_sign_in_at: 1.day.ago, confirmed_at: 2.day.ago)
    john = User.create(name: 'John', last_sign_in_at: 2.week.ago, confirmed_at: 1.month.ago)

    expect(UserRepository.confirmed).to contain_exactly(john, mary)
    expect(UserRepository.active).to contain_exactly(mary)
  end

  it 'raises domain method error when directly calls domain methods' do
    expect { UserRepository.alphabetically }.to raise_error(Repositorish::DomainMethodError)
  end
end
