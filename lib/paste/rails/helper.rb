require 'digest/sha1'

module Paste
  module Rails
    module Helper
      def javascript_tags *javascripts
        include_javascripts *javascripts

        results = Paste::Rails.glue.paste *@javascripts
        all_js = results[:javascripts]

        cache = Digest::SHA1.hexdigest(all_js.sort.join)[0..12]
        all_js << {:cache => cache} unless Paste::JS.config.no_cache

        javascript_include_tag *all_js
      end

      def stylesheet_tags *other_css
        include_stylesheets *other_css

        results = Paste::Rails.glue.paste *(@javascripts ||= [])
        all_css = (results[:stylesheets] + @css).uniq

        cache = Digest::SHA1.hexdigest(all_css.sort.join)[0..12]
        all_css << {:cache => cache} unless Paste::CSS.config.no_cache

        stylesheet_link_tag *all_css
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

      alias :stylesheet :include_stylesheets
      alias :include_stylesheet :include_stylesheets
    end
  end
end
