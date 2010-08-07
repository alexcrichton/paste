module Paste
  module Rails
    module Helper
      def paste_tags *javascripts
        include_javascripts *javascripts

        return if @javascripts.empty?

        results = Paste::Rails.glue.paste *@javascripts

        javascript_include_tag *results
      end

      def include_javascripts *javascripts
        @javascripts ||= []
        @javascripts += javascripts.flatten
        @javascripts.uniq!
      end

      def included_javascripts
        @javascripts
      end

      alias :include_javascript :include_javascripts
      alias :include_js :include_javascripts
      alias :javascript :include_javascripts
    end
  end
end