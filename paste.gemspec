# -*- encoding: utf-8 -*-

require File.expand_path('../lib/paste/version', __FILE__)

Gem::Specification.new do |s|
  s.name     = 'paste'
  s.version  = Paste::VERSION
  s.platform = Gem::Platform::RUBY

  s.author      = 'Alex Crichton'
  s.homepage    = 'http://github.com/alexcrichton/paste'
  s.email       = 'alex@alexcrichton.com'
  s.description = 'Asset Management for Rails'
  s.summary     = 'JS and CSS dependency management'

  s.files            = `git ls-files lib`.split("\n") + ['README.rdoc']
  s.test_files       = `git ls-files spec`.split("\n")
  s.extra_rdoc_files = ['README.rdoc']
  s.rdoc_options     = ['--charset=UTF-8']
  s.require_path     = 'lib'

  s.add_dependency 'sprockets'
  s.add_dependency 'activesupport', '~> 3.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'actionpack', '~> 3.0'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'guard-bundler'
  s.add_development_dependency 'growl'
  s.add_development_dependency 'rspec'
end
