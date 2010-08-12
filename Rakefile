require 'rubygems'
require 'bundler/setup'

require 'paste/version'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  gem.name        = 'paste'
  gem.authors     = ['Alex Crichton']
  gem.description = 'Asset Management for Rails'
  gem.summary     = 'JS and CSS dependency management'
  gem.email       = ['alex@alexcrichton.com']
  gem.homepage    = 'http://github.com/alexcrichton/paste'

  gem.add_bundler_dependencies
end
Jeweler::GemcutterTasks.new

namespace :gem do
  desc "Push the gem to rubygems.org"
  task :push do
    system "gem push pkg/paste-#{Paste::VERSION}.gem"
  end
end
