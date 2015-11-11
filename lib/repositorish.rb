require 'active_support/core_ext/string/inflections'
require 'repositorish/version'

# Simple Repository(ish) solution to hold query and command logic into
# self contained objects
#
# # Example:
#
# ```ruby
# class UserRepository
#   include Repositorish
#
#   repositorish :user, scope: :all
#
#   def confirmed
#     where.not(confirmed_at: nil)
#   end
# end
#
# UserRepository.confirmed
# # => <User::ActiveRecord_Relation ...>
# ```
module Repositorish
  CHAINABLE_NAMESPACES = %w(ActiveRecord ActiveRecord_Relation ActiveRecord_AssociationRelation)
  CHAINABLE_NAMESPACES_REGEX = /(?:^|::)(?:#{CHAINABLE_NAMESPACES.join('|')})(?:$|::)/.freeze

  def self.included(base)
    base.send :extend, ClassMethods
  end

  def initialize(domain)
    @domain = domain
  end

  def method_missing(method, *args, &block)
    return super unless domain.respond_to?(method)

    result = domain.public_send(method, *args, &block)
    return result unless chainable?(result)

    @domain = result
    self
  end

  def to_ary
    @domain.to_ary
  end

  private

  attr_reader :domain

  def arel_table
    domain.arel_table
  end

  def chainable?(domain)
    return true if CHAINABLE_NAMESPACES_REGEX =~ domain.class.to_s

    domain.class == @domain.class
  end

  # :nodoc:
  module ClassMethods
    def repositorish(model, options = {})
      @domain = model.to_s.classify.constantize
      @domain = @domain.public_send(options[:scope]) if options[:scope]
      self
    end

    def create(model, *args, &block)
      return false if model.persisted?

      model.save(*args, &block)
    end

    def update(model, *args, &block)
      return false if model.new_record?

      model.save(*args, &block)
    end

    def destroy(model)
      return if model.new_record?

      model.destroy
    end

    def query(domain = @domain)
      new(domain)
    end

    def method_missing(method, *args, &block)
      return query.public_send(method, *args, &block) if method_defined?(method)

      fail DomainMethodError, method if @domain.respond_to?(method)
      super
    end
  end

  # Custom error that warns users when calling domain's methods directly on repository
  # It avoid users to use repositories as actual models
  class DomainMethodError < NoMethodError
    def initialize(method, *args)
      super("Direct call on domain's methods is not allowed", method, *args)
    end
  end
end
