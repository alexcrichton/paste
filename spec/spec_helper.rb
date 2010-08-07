require 'rubygems'
require 'bundler/setup'

Bundler.require :default, :test

require 'fileutils'
require 'rspec/core'
require 'paste'

Paste::JS.configure do |config|
  config.root        = File.dirname(__FILE__) + '/tmp'
  config.load_path   = ['sources']
end

RSpec.configure do |c|
  c.color_enabled = true

  c.after(:each) do
    FileUtils.rm_rf Paste::JS.config.root
  end
end

Dir[File.dirname(__FILE__) + '/support/*.rb'].each { |f| load f }
