module Sprockets
  module Rails
    module Helper
      def sprockets_include_tag
        return if @sprockets.blank?

        javascript_include_tag Sprockets::Rails.path_for_sources @sprockets
      end

      def include_sprocket sprocket
        include_sprockets [sprocket]
      end

      def include_sprockets *sprockets
        @sprockets ||= []
        @sprockets += sprockets.flatten
        @sprockets.uniq!
      end
    end
  end
end
