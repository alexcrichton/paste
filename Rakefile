$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'sprockets/rails/version'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "sprockets-rails"
    gem.version = Sprockets::Rails::Version::STRING
    gem.summary = "sprockets-rails-#{Sprockets::Rails::Version::STRING}"
    gem.description = "Sprockets for Rails 3"
    gem.email = "alex@alexcrichton.com"
    gem.homepage = "http://github.com/alexcrichton/sprockets-rails"
    gem.authors = ["Alex Crichton"]
    gem.add_dependency "sprockets"
    gem.post_install_message = <<-EOM
#{"*"*50}

  Thank you for installing #{gem.summary}!

  This version of sprockets-rails only works with 
  versions of rails >= 3.0.0.pre.

  Be sure to run the following command in each of your
  Rails apps if you're installing:

    script/rails generate sprockets

#{"*"*50}
EOM
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

