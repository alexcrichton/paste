require 'bundler'
Bundler.require

require 'fileutils'

Paste.configure do |config|
  config.root           = File.expand_path('../tmp', __FILE__)
  config.js_load_path   = ['js_sources']
  config.js_destination = 'destination'
end

RSpec.configure do |c|
  c.after(:each) do
    FileUtils.rm_rf Paste.config.root
  end
end

Dir[File.dirname(__FILE__) + '/support/*.rb'].each { |f| load f }
