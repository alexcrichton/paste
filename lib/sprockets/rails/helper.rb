module Sprockets
  module Rails
    module Helper
      def sprockets_include_tag *sprockets
        (@sprockets ||= []) += sprockets
        return if @sprockets.blank?

        file = Sprockets::Rails.watcher.sprocketize @sprockets

        javascript_include_tag file
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
