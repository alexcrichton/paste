module Paste
  module Rails
    class Updater

      def initialize app
        @app = app
      end

      def call env
        Paste::Rails.glue.rebuild
        @app.call env
      end

    end
  end
end