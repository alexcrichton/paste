$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'sprockets/packager/version'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "sprockets-packager"
    gem.version = Sprockets::Packager::Version::STRING
    gem.summary = "sprockets-packager-#{Sprockets::Packager::Version::STRING}"
    gem.description = "Sprocket Packaging for Rails 3"
    gem.email = "alex@alexcrichton.com"
    gem.homepage = "http://github.com/alexcrichton/sprockets-packager"
    gem.authors = ["Alex Crichton"]
    gem.add_dependency "sprockets"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

namespace :gem do
  desc "push to gemcutter"
  task :push => :build do
    system "gem push pkg/sprockets-packager-#{Sprockets::Packager::Version::STRING}.gem"
  end
end

namespace :sprockets do
  desc "Install gems and run the tests"
  task :test do
    destination = File.expand_path('../tmp', __FILE__)
    FileUtils.mkdir_p destination
    system "bundle install #{destination}"
    exec "bundle exec rspec spec --color"
  end
end