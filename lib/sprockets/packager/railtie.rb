require 'fileutils'
require 'digest/sha1'

require 'sprockets'
require 'sprockets/packager'
require 'sprockets/packager/rack'
require 'sprockets/packager/helper'
require 'sprockets/packager/watcher'
require 'sprockets/packager/erb_helper'

module Sprockets
  module Packager
    class Railtie < Rails::Railtie
      
      if Sprockets::Packager.options[:watch_changes]
        config.app_middleware.use Sprockets::Packager::Rack
      end

      config.to_prepare do 
        ActionView::Base.send :include, Sprockets::Packager::Helper

        Sprockets::Packager.watcher.prepare!
      end

    end
  end
end