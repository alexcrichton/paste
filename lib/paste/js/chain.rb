module Paste
  module JS
    class Chain < Base

      def paste *sources
        dependencies = []
        current_path = []
        
        sources.each do |source|
          in_order_traversal source, dependencies, current_path
          register_secretary [source] unless has_secretary? source
        end

        dependencies.each do |source|
          source << '.js' unless source.end_with? '.js'
          file = destination source

          write_sprocket source if needs_update?(file, File.mtime(find(source)))
        end
      end

      def write_sprocket sprocket
        file = destination sprocket

        FileUtils.mkdir_p File.dirname(file)
        FileUtils.cp find(sprocket), file
      end

      def sprocket_name sprockets
        result = sprockets.first
        result += '.js' unless result.end_with?('.js')
        result
      end

      protected

      def in_order_traversal source, dependencies, current_path
        return if dependencies.include? source
        raise "Circular dependency at #{source}!" if current_path.include? source

        current_path.push source

        source_file = Sprockets::SourceFile.new environment, 
            Sprockets::Pathname.new(environment, find(source))
        source_file.source_lines.each do |line|
          if line.require?
            to_require = line.require[/^.(.*).$/, 1]
            in_order_traversal to_require, dependencies, current_path
          end
        end

        dependencies.push current_path.pop
      end

    end
  end
end