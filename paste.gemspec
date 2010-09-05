# -*- encoding: utf-8 -*-
$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'paste/version'

Gem::Specification.new do |s|
  s.name     = 'paste'
  s.version  = Paste::VERSION
  s.platform = Gem::Platform::RUBY  

  s.author           = 'Alex Crichton'
  s.homepage         = 'http://github.com/alexcrichton/paste'
  s.email            = 'alex@alexcrichton.com'
  s.description      = 'Asset Management for Rails'
  s.summary          = 'JS and CSS dependency management'

  s.files            = `git ls-files lib/*`.split("\n") + ['README.rdoc']
  s.test_files       = `git ls-files spec/*`.split("\n")
  s.extra_rdoc_files = ['README.rdoc']
  s.rdoc_options     = ['--charset=UTF-8']
  s.require_path     = 'lib'

  s.add_runtime_dependency 'sprockets'
  s.add_runtime_dependency 'closure-compiler'
  s.add_runtime_dependency 'activesupport', '>= 3.0.0.beta4'
end
