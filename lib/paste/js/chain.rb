module Paste
  module JS
    class Chain < Base

      def paste *sources
        dependencies = []

        sources.each do |source|
          register [source] unless registered? [source]
          source_deps  = results[result_name([source])][:parser].dependencies
          dependencies = dependencies | source_deps
        end
        dependencies.map! do |d| 
          register [d] unless registered? [d] # implicit dependencies
          result_name [d]
        end

        dependencies.each do |dep|
          write_result dep if needs_update?(dep)
        end

        dependencies
      end

      def write_result result
        file = destination result

        FileUtils.mkdir_p File.dirname(file)
        FileUtils.cp find(result), file
      end

      def result_name sources
        result = sources.first
        result += '.js' unless result.end_with?('.js')
        result
      end

    end
  end
end
