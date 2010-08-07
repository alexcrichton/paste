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

        dependencies.map do |d| 
          result = result_name [d]
          register [d] unless registered? [d] # implicit dependencies
          write_result result if needs_update?(result)

          result
        end
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
