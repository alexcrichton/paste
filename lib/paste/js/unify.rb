require 'digest/sha1'

module Paste
  module JS
    class Unify < Base

      def paste *sources
        result = result_name sources

        register sources unless registered?(sources)

        if needs_update?(result) || needs_dependency_update?(result)
          results[result][:parser].reset!
          write_result result
        end

        {
          :javascripts => [result],
          :stylesheets => results[result][:parser].css_dependencies
        }
      end

      def write_result result
        path = destination result
        FileUtils.mkdir_p File.dirname(path)

        results[result][:parser].reset!
        results[result][:parser].concatenation.save_to path
      end

      def result_name sources
        to_digest = sources.map{ |s| s.gsub /\.js$/, '' }.sort.join
        Digest::SHA1.hexdigest(to_digest)[0..12] + '.js'
      end

    end
  end
end
