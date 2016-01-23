require 'rake'
require 'date'
require File.join(File.dirname(__FILE__), 'lib/openapi/version')

Gem::Specification.new do |s|
  s.name = 'openapi'
  s.version = ::OpenAPI::VERSION
  s.licenses = ['MIT']
  s.date = Date.today.to_s
  s.summary = 'A Ruby library to build api wrapper'
  s.description = 'A lots of service expose a more or less complex API. The library provides common tasks to easily build a ruby wrapper'
  s.homepage = 'http://github.com/ant31/openapi'
  s.authors = ['Antoine Legrand']
  s.email = ['ant.legrand@gmail.com']
  s.files = FileList['README.md', 'LICENSE', 'Changelog','Rakefile', 'lib/**/*.rb'].to_a
  s.test_files = FileList['spec/**/*.rb'].to_a

  s.add_dependency 'json', [ "~> 1.8" ]
  s.add_dependency 'activesupport', [ ">= 3" ]
  s.add_dependency 'hashie'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'fakeweb'

  s.required_ruby_version = '>= 1.9.2'
end
