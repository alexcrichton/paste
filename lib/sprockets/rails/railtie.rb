require 'fileutils'
require 'digest/sha1'

require 'sprockets'
require 'sprockets/rails'
require 'sprockets/rails/rack'
require 'sprockets/rails/helper'
require 'sprockets/rails/watcher'

module Sprockets
  module Rails
    class Railtie < ::Rails::Railtie
      
      if Sprockets::Rails.options[:watch_changes]
        config.app_middleware.use Sprockets::Rails::Rack
      end

      config.to_prepare do 
        ActionView::Base.send :include, Sprockets::Rails::Helper
        
        Sprockets::Rails.watcher.prepare!
      end

    end
  end
end