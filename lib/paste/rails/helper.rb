require 'digest/sha1'

module Paste
  module Rails
    module Helper

      def javascript_tags *javascripts
        include_javascripts *javascripts

        results = Paste::Rails.glue.paste *@javascripts

        javascript_include_tag *add_cache_argument(results[:javascripts])
      end

      def stylesheet_tags *other_css
        include_stylesheets *other_css

        results = Paste::Rails.glue.paste *(@javascripts ||= [])
        all_css = (results[:stylesheets] + @css).uniq

        stylesheet_link_tag *add_cache_argument(all_css)
      end

      def include_javascripts *javascripts
        @javascripts ||= []
        @javascripts += javascripts.flatten
        @javascripts.uniq!
      end

      def included_javascripts
        @javascripts
      end

      def include_stylesheets *css
        @css ||= []
        @css += css.flatten
        @css.uniq!
      end

      def included_stylesheets
        @css
      end

      alias :include_javascript :include_javascripts
      alias :javascript :include_javascripts
      alias :javascripts :include_javascripts

      alias :stylesheet :include_stylesheets
      alias :stylesheets :include_stylesheets
      alias :include_stylesheet :include_stylesheets

      protected

      def add_cache_argument sources
        if Paste.config.no_cache
          sources
        else
          cache = Digest::SHA1.hexdigest(sources.sort.join)[0..12]
          sources + [{:cache => cache}]
        end
      end

    end
  end
end
