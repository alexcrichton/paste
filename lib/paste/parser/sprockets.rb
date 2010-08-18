require 'sprockets'

module Paste
  module Parser
    class Sprockets

      attr_reader :glue, :secretary, :sources

      delegate :concatenation, :to => :secretary

      def initialize glue, sources
        @glue      = glue
        @sources   = sources
        reset!
      end

      def js_dependencies
        generate_dependencies if @js_dependencies.nil?
        @js_dependencies
      end

      def css_dependencies
        generate_dependencies if @css_dependencies.nil?
        @css_dependencies
      end

      def reset!
        @js_dependencies = @css_dependencies = nil

        @secretary = ::Sprockets::Secretary.new(
          :root         => glue.root, 
          :expand_paths => false,
          :load_path    => glue.load_path,
          :source_files => @sources.map{ |s| glue.find s }
        )
      rescue ::Sprockets::LoadError => e
        raise ResolveError.new(e.message)
      end

      protected

      def environment
        @environment ||= ::Sprockets::Environment.new glue.root,
            glue.load_path
      end

      def generate_dependencies
        @js_dependencies  = []
        @css_dependencies = []
        sources.each { |source| in_order_traversal source }
      end

      def in_order_traversal source, current_path = []
        return if @js_dependencies.include? source
        raise "Circular dependency at #{source}" if current_path.include? source

        current_path.push source

        source_file = ::Sprockets::SourceFile.new environment, 
            ::Sprockets::Pathname.new(environment, glue.find(source))
        css_deps = []
        source_file.source_lines.each do |line|
          if line.require?
            in_order_traversal line.require[/^.(.*).$/, 1], current_path
          elsif line.css_require?
            css_deps << line.css_require
          end
        end
      
        @js_dependencies.push current_path.pop
        @css_dependencies = @css_dependencies | css_deps
      end

    end    
  end
end

module Sprockets
  class SourceLine
    def css_require?
      !!css_require
    end

    def css_require
      @css_require ||= (comment || "")[/^=\s+require_css\s+<(.*?)>\s*$/, 1]
    end
  end
end
