require 'rubygems'
require 'bundler'

Bundler.setup :default

require 'sprockets/packager/version'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  gem.name        = 'sprockets-packager'
  gem.version     = Sprockets::Packager::Version::STRING
  gem.summary     = "sprockets-packager-#{Sprockets::Packager::Version::STRING}"
  gem.description = 'Sprocket Packaging for Rails 3'
  gem.email       = 'alex@alexcrichton.com'
  gem.homepage    = 'http://github.com/alexcrichton/sprockets-packager'
  gem.authors     = ['Alex Crichton']
  gem.add_dependency 'sprockets'
end

namespace :gem do
  desc 'push to gemcutter'
  task :push => :build do
    system 'bundle exec gem push ' +
           "pkg/sprockets-packager-#{Sprockets::Packager::Version::STRING}.gem"     
  end
end
