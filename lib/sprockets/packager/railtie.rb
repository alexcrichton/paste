module Sprockets
  module Packager
    class Railtie < Rails::Railtie
      
      initializer 'sprockets_packager.' do
        Sprockets::Packager.options.merge!(
          :watch_changes   => Rails.env.development?,
          :expand_includes => Rails.env.development?,
          :root            => Rails.root
        )

        ActionView::Base.send :include, Sprockets::Packager::Helper

        Sprockets::Packager.watcher.prepare!
        
        if Sprockets::Packager.options[:watch_changes]
          require 'sprockets/packager/rack_updater'
          config.app_middleware.use Sprockets::Packager::RackUpdater
        end

        if Sprockets::Packager.options[:serve_assets]
          Sprockets::Packager.options[:destination] = Sprockets::Packager.options[:tmp_path] + '/javascripts'
          Sprockets::Packager.reset!

          # We want this serving to be at the very front
          config.app_middleware.insert_before ActionDispatch::Static, 
              ::Rack::Static, 
              :urls => ['/javascripts'], 
              :root => Sprockets::Packager.watcher.tmp_path
        end
      end
    end
  end
end
