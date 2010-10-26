require 'sprockets'

module Paste
  module Parser
    class Sprockets

      attr_reader :glue, :source, :file

      def initialize glue, source
        @glue   = glue
        @source = source
        @file   = glue.find source
      end

      def js_dependencies
        reset_if_needed
        @js_dependencies
      end

      def css_dependencies
        reset_if_needed
        @css_dependencies
      end

      def copy_if_needed
        dest = glue.destination(source)

        if !File.exists?(dest) || File.mtime(dest) != File.mtime(@file)
          FileUtils.mkdir_p File.dirname(dest)
          FileUtils.cp @file, dest
          File.utime File.mtime(@file), File.mtime(@file), dest
        end
      end

      def reset_if_needed
        if @js_dependencies.nil? || @css_dependencies.nil? ||
            @last_updated.nil? || @last_updated < File.mtime(@file)

          @last_updated    = Time.now

          @secretary = ::Sprockets::Secretary.new(
            :root         => glue.root,
            :expand_paths => false,
            :load_path    => glue.load_path,
            :source_files => [@file]
          )

          generate_dependencies
        end
      end

      protected

      def environment
        @environment ||= ::Sprockets::Environment.new glue.root,
            glue.load_path
      end

      def generate_dependencies
        @js_dependencies  = []
        @css_dependencies = []

        source_file = ::Sprockets::SourceFile.new environment,
            ::Sprockets::Pathname.new(environment, @file)

        source_file.source_lines.each do |line|
          if line.require?
            @js_dependencies << line.require[/^.(.*).$/, 1]
          elsif line.css_require?
            @css_dependencies << line.css_require
          end
        end
      end

      module CSSLine
        def css_require?
          !!css_require
        end

        def css_require
          @css_require ||= (comment || "")[/^=\s+require_css\s+<(.*?)>\s*$/, 1]
        end
      end

    end
  end
end

Sprockets::SourceLine.class_eval{ include Paste::Parser::Sprockets::CSSLine }
