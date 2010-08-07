require 'sprockets'

module Paste
  module Parser
    class Sprockets

      attr_reader :glue, :secretary, :sources

      delegate :concatenation, :to => :secretary

      def initialize glue, sources
        @glue      = glue
        @sources   = sources
        @secretary = ::Sprockets::Secretary.new(
          :root         => glue.root, 
          :expand_paths => false,
          :load_path    => glue.load_path,
          :source_files => sources.map{ |s| glue.find s }
        )
      end

      def dependencies
        deps = []
        sources.each { |source| in_order_traversal source, deps }
        deps
      end
      
      def reset!
        secretary.reset!
      rescue ::Sprockets::LoadError => e
        raise ResolveError.new(e.message)
      end

      protected

      def environment
        @environment ||= ::Sprockets::Environment.new glue.root,
            glue.load_path
      end

      def in_order_traversal source, dependencies, current_path = []
        return if dependencies.include? source
        raise "Circular dependency at #{source}" if current_path.include? source

        current_path.push source

        source_file = ::Sprockets::SourceFile.new environment, 
            ::Sprockets::Pathname.new(environment, glue.find(source))

        source_file.source_lines.each do |line|
          if line.require?
            in_order_traversal line.require[/^.(.*).$/, 1], dependencies,
                current_path
          end
        end
      
        dependencies.push current_path.pop
      end

    end    
  end
end
