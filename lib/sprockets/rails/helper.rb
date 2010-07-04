module Sprockets
  module Rails
    module Helper
      def sprockets_include_tag *sprockets
        include_sprockets *sprockets
        
        @sprockets.flatten!
        @sprockets.uniq!
        
        return if @sprockets.blank?

        file = Sprockets::Rails.watcher.sprocketize @sprockets

        javascript_include_tag file
      end

      def include_sprockets *sprockets
        @sprockets ||= []
        @sprockets += sprockets
      end
      
      alias :include_sprocket :include_sprockets
    end
  end
end
