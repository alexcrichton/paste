require 'digest/sha1'

module Paste
  module Rails
    module Helper
      def paste_js_tags *javascripts
        include_javascripts *javascripts

        return '' if @javascripts.empty?

        results = Paste::Rails.glue.paste *@javascripts

        javascript_include_tag(*results[:javascript])
      end

      def paste_css_tags *other_css
        include_css *other_css

        results = Paste::Rails.glue.paste *(@javascripts ||= [])
        all_css = (results[:css] + @css).uniq
        
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

      def include_css *css
        @css ||= []
        @css += css.flatten
        @css.uniq!
      end

      def included_css
        @css
      end

      alias :include_javascript :include_javascripts
      alias :javascript :include_javascripts
      
      alias :css :include_css
    end
  end
end