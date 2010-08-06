require 'rubygems'
require 'bundler/setup'

Bundler.require :default, :test

require 'fileutils'
require 'rspec/core'
require 'paste'

tmp_dir = File.expand_path('../tmp', __FILE__)

Paste::JS.configure do |config|
  config.root        = tmp_dir
  config.tmp_path    = 'temporary'
  config.destination = 'destination'
  config.load_path   = [tmp_dir + '/sources']
end

RSpec.configure do |c|
  c.color_enabled = true

  c.before(:each) do
    Paste::JS::Base.config.load_path.each { |p| FileUtils.mkdir_p p }
  end

  c.after(:each) do
    FileUtils.rm_rf tmp_dir
  end
end

Dir[File.dirname(__FILE__) + '/support/*.rb'].each { |f| load f }
