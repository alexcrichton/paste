module Sprockets
  module Packager
    class ERBHelper < ERB
      include ActionView::Helpers if defined?(ActionView::Helpers)

      def config
        Rails.application.config.action_controller if defined?(Rails)
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