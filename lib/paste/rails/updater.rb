module Paste
  module Rails
    class Updater

      def initialize app
        @app = app
      end

      def call env
        Paste::Rails.glue.update_registered
        @app.call env
      end

    end
  end
end