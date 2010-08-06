require 'digest/sha1'

module Paste
  module JS
    class Unify < Base

      def paste *sources
        result = result_name sources

        register sources unless registered?(sources)

        if needs_update?(result)
          write_result result
        end

        [result]
      end

      def write_result result
        path = destination result
        FileUtils.mkdir_p File.dirname(path)

        if needs_update?(result)
          results[result][:parser].reset!
        end

        results[result][:parser].concatenation.save_to path
      end

      def result_name sources
        to_digest = sources.map{ |s| s.gsub /\.js$/, '' }.sort.join
        Digest::SHA1.hexdigest(to_digest)[0..12] + '.js'
      end

    end
  end
end