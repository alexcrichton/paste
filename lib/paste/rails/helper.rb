require 'digest/sha1'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/string/output_safety'

module Paste
  module Rails
    module Helper

      attr_accessor :included_javascripts, :included_stylesheets

      def javascript_tags *javascripts
        include_javascripts *javascripts

        results = Paste::Rails.glue.paste(*@included_javascripts)[:javascripts]

        javascript_include_tag *add_cache_argument(results)
      end

      def stylesheet_tags *stylesheets
        include_stylesheets *stylesheets
        @included_javascripts ||= []

        results = Paste::Rails.glue.paste(*@included_javascripts)[:stylesheets]
        include_stylesheets *results

        @included_stylesheets.map do |opts, sheets|
          next if sheets.size == 0
          stylesheet_link_tag *add_cache_argument(sheets.dup << opts.dup)
        end.join.html_safe
      end

      def include_javascripts *javascripts
        @included_javascripts ||= []
        @included_javascripts += javascripts.flatten
        @included_javascripts.uniq!
      end

      def include_stylesheets *stylesheets
        @included_stylesheets ||= Hash.new{ |h, k| h[k] = [] }
        opts = stylesheets.extract_options! || {}
        @included_stylesheets[opts] += stylesheets.flatten
        @included_stylesheets[opts].uniq!
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
          opts = sources.extract_options! || {}
          opts[:cache] = Digest::SHA1.hexdigest(sources.sort.join)[0..12]
          sources << opts
        end
      end

    end
  end
end
