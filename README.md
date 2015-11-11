# Repositorish
[![Build Status](https://travis-ci.org/LoveMondays/repositorish.svg)](https://travis-ci.org/LoveMondays/repositorish) [![Code Climate](https://codeclimate.com/github/LoveMondays/repositorish/badges/gpa.svg)](https://codeclimate.com/github/LoveMondays/repositorish) [![Test Coverage](https://codeclimate.com/github/LoveMondays/repositorish/badges/coverage.svg)](https://codeclimate.com/github/LoveMondays/repositorish/coverage)

Simple Repository(ish) solution to hold query and command logic into self contained objects

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'repositorish'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install repositorish

## Usage

```ruby
class User < ActiveRecord::Base
  scope :alphabetically, -> { order(name: :asc) }
end
```

```ruby
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
```

```ruby
  john = User.new(name: 'John')
  john.new_record?
  # => true

  UserRepository.create(user)
  # => true

  john.persisted?
  # => true

  john.last_sign_in_at = 2.week.ago
  john.confirmed_at = 1.month.ago
  UserRepository.update(user)
  # => true

  mary = User.new(name: 'Mary', last_sign_in_at: 1.day.ago, confirmed_at: 2.day.ago)
  UserRepository.create(mary)
  # => true

  UserRepository.confirmed
  # => [#<User name: 'John'>]

  UserRepository.active
  # => [#<User name: 'Mary'>]

  UserRepository.alphabetically
  # => Repositorish::DomainMethodError: Direct call on domain's methods is not allowed

  UserRepository.active.destroy_all
  # => [#<User name: 'Mary'>]

  UserRepository.destroy(john)
  # => #<User name: 'John'>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/LoveMondays/repositorish/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
