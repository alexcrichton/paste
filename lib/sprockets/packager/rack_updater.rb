module Sprockets
  module Packager
    class RackUpdater

      def initialize app
        @app = app
      end
      
      def call env
        Sprockets::Packager.watcher.prepare!
        Sprockets::Packager.watcher.update_sprockets

        @app.call env
      end

    end
  end
end