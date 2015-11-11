lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'warehouse/version'

Gem::Specification.new do |s|
  s.name        = 'warehouse'
  s.version     = Warehouse::VERSION
  s.platform    = Gem::Platform::RUBY

  s.date        = '2015-11-10'
  s.summary     = 'Simple Repository(ish) solution to hold query and ' \
                  'command logic into self contained objects'
  s.homepage    = 'https://github.com/LoveMondays/warehouse'
  s.license     = 'MIT'

  s.authors     = ['Glauber Campinho', 'Brenno Costa']
  s.email       = ['ggcampinho@gmail.com', 'brennolncosta@gmail.com']
  s.files       = `git ls-files -z`.split("\x0")

  s.add_dependency 'activesupport'

  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'codeclimate-test-reporter'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.3.0'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'sqlite3'
end
