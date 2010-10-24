module Paste
  module Rails
    class Railtie < ::Rails::Railtie

      initializer 'paste_initializer' do
        Paste.config.root = ::Rails.root
        ActionView::Base.class_eval { include Helper }

        if ::Rails.env.development?
          config.app_middleware.use Paste::Rails::Updater
        else
          config.to_prepare do
            Paste::Rails.glue.render_all_erb
            Paste::Rails.glue.rebuild
          end
        end

        if Paste.config.serve_assets
          Paste.config.js_destination = 'tmp/javascripts'

          # We want this serving to be at the very front
          config.app_middleware.insert_before Rack::Runtime,
              ::Rack::Static,
              :urls => ['/javascripts'],
              :root => File.dirname(Paste.config.js_destination)
        end
      end

      rake_tasks do
        load 'paste/tasks/paste.rake'
      end

    end
  end
end
