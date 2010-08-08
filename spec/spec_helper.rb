require 'rubygems'
require 'bundler/setup'

Bundler.require :default, :test

require 'fileutils'
require 'rspec/core'
require 'paste'

Paste::Glue.configure do |config|
  config.root        = File.dirname(__FILE__) + '/tmp'
end

Paste::JS.config.load_path  = ['js_sources']
Paste::JS.config.destination  = 'destination'
Paste::CSS.config.load_path = ['css_sources']
Paste::CSS.config.destination  = 'destination'


RSpec.configure do |c|
  c.color_enabled = true

  c.after(:each) do
    FileUtils.rm_rf Paste::Glue.config.root
  end
end

Dir[File.dirname(__FILE__) + '/support/*.rb'].each { |f| load f }
