require 'sprockets/environment'

module Paste
  module JS
    class Base < Glue

      def update_registered
        secretaries.each_pair do |result, secretary|
          if needs_update?(destination(result), secretary.source_last_modified)
            write_sprocket result
          end
        end
      end

      def register_secretary sources
        secretaries[sprocket_name(sources)] = Sprockets::Secretary.new(
          :root         => root, 
          :expand_paths => false,
          :load_path    => load_path,
          :source_files => sources.map{ |s| find s }
        )
      end

      def secretaries
        @secretaries ||= {}
      end

      def has_secretary? sprocket
        secretaries.key? sprocket
      end

    end
  end
end
