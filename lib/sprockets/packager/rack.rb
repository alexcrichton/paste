module Sprockets
  module Packager
    class Rack

      def initialize app
        @app = app
      end
      
      def call env
        Sprockets::Packager.check_for_updates
        @app.call env
      end

    end
  end
end