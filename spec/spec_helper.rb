require 'rubygems'
require 'bundler/setup'

require 'fileutils'
require 'rspec/core'
require 'paste'

Paste::Glue.configure do |config|
  config.root = File.expand_path('../tmp', __FILE__)
end

Paste::JS.config.load_path  = ['js_sources']
Paste::JS.config.destination  = 'destination'

RSpec.configure do |c|
  c.color_enabled = true

  c.after(:each) do
    FileUtils.rm_rf Paste::Glue.config.root
  end
end

Dir[File.dirname(__FILE__) + '/support/*.rb'].each { |f| load f }
