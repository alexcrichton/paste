require 'digest/sha1'

module Paste
  module JS
    class Unify < Base

      def paste *sprockets
        to_generate = sprocket_name sprockets

        register_secretary sprockets unless has_secretary?(to_generate)

        if needs_update?(destination(to_generate),
            secretaries[to_generate].source_last_modified)
          write_sprocket to_generate
        end

        [to_generate]
      end

      
      def write_sprocket sprocket
        path = destination sprocket
        FileUtils.mkdir_p File.dirname(path)

        if needs_update?(path, secretaries[sprocket].source_last_modified)
          secretaries[sprocket].reset!
        end

        secretaries[sprocket].concatenation.save_to path
      end

      def sprocket_name sprockets
        to_digest = sprockets.map{ |s| s.gsub /\.js$/, '' }.sort.join
        Digest::SHA1.hexdigest(to_digest)[0..12] + '.js'
      end

      # The cache chains the paste method and the compress chains the rebuild!
      # method so these need to be down here
      include Cache
      include Compress

    end
  end
end