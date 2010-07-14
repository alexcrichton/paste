module Sprockets
  module Packager
    class ERBHelper < ERB
      include ActionView::Helpers

      def config
        Rails.application.config.action_controller
      end
  
      def result *args
        super binding
      end

      def controller
        nil
      end
    end
  end
end