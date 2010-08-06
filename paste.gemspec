# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name    = 'paste'
  s.version = '0.0.1'

  s.authors               = ['Alex Crichton']
  s.date                  = Date.today
  s.description           = 'Asset Management for Rails'
  s.summary               = 'JS and CSS dependency management'
  s.email                 = ['alex@alexcrichton.com']
  s.extra_rdoc_files      = ['README.rdoc']
  s.files                 = Dir.glob("{bin,lib}/**/*") + %w(README.rdoc)
  s.homepage              = 'http://github.com/alexcrichton/paste'
  s.rdoc_options          = ['--main', 'README.rdoc']
  s.require_paths         = ['lib']
  s.rubygems_version      = '1.3.5'
  s.specification_version = 3

  s.add_dependency 'activesupport', ['>= 3.0.0.beta4']
  s.add_dependency 'sprockets'
  s.add_dependency 'haml'

  s.add_development_dependency 'rspec', ['>= 2.0.0.beta.19']
end
