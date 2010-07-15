module Sprockets
  module Packager
    class Railtie < Rails::Railtie
      
      if Sprockets::Packager.watcher.watch_changes
        config.app_middleware.use Sprockets::Packager::Rack
      end

      config.to_prepare do 
        ActionView::Base.send :include, Sprockets::Packager::Helper

        Sprockets::Packager.watcher.prepare!
      end

    end
  end
end