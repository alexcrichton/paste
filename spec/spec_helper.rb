require 'rubygems'
require 'bundler/setup'

require 'fileutils'
require 'rspec/core'
require 'paste'

Paste.configure do |config|
  config.root = File.expand_path('../tmp', __FILE__)
end

Paste.config.js_load_path  = ['js_sources']
Paste.config.js_destination  = 'destination'

RSpec.configure do |c|
  c.after(:each) do
    FileUtils.rm_rf Paste.config.root
  end
end

Dir[File.dirname(__FILE__) + '/support/*.rb'].each { |f| load f }
