module Sprockets
  module Packager
    class Railtie < Rails::Railtie
      
      if Rails.env.development?
        config.app_middleware.use Sprockets::Packager::Rack
      end

      config.to_prepare do 
        ActionView::Base.send :include, Sprockets::Packager::Helper

        Sprockets::Packager.options.merge!(
          :root            => Rails.root,
          :watch_changes   => Rails.env.development?,
          :expand_includes => Rails.env.development?
        )
        Sprockets::Packager.watcher.prepare!
      end

    end
  end
end
