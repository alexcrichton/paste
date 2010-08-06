module Paste
  module Rails
    class Railtie < Rails::Railtie
  
      initializer 'paste_initializer' do
        Paste::JS.config.root = Rails.root
        ActionView::Base.send :include, Helper

        if Rails.env.development?
          Paste::Rails.glue = Paste::JS::Chain.new
          config.app_middleware.use Paste::Rails::Updater
        else
          Paste::Rails.glue = Paste::JS::Unify.new
        end

        if Paste::Rails.config.serve_assets
          Paste::Rails.config.destination = 'tmp/javascripts'

          # We want this serving to be at the very front
          config.app_middleware.insert_before Rack::Runtime,
              ::Rack::Static, 
              :urls => ['/javascripts'],
              :root => Paste::Rails.tmp_path
        end
      end

      rake_tasks do
        load 'paste/tasks/sprockets_packager.rake'
      end
  
    end
  end
end