$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'sprockets/rails/version'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "sprockets-packager"
    gem.version = Sprockets::Rails::Version::STRING
    gem.summary = "sprockets-rails-#{Sprockets::Rails::Version::STRING}"
    gem.description = "Sprocket Packaging for Rails 3"
    gem.email = "alex@alexcrichton.com"
    gem.homepage = "http://github.com/alexcrichton/sprockets-packager"
    gem.authors = ["Alex Crichton"]
    gem.add_dependency "sprockets"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

