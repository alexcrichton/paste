module Sprockets
  module Rails
    class Rack

      def initialize app
        @app = app
      end
      
      def call env
        Sprockets::Rails.check_for_updates
        @app.call env
      end

    end
  end
end