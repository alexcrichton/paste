require 'yaml'

module Paste
  module JS
    module Cache
      extend ActiveSupport::Concern
      
      included do
        alias_method_chain :paste, :cache
      end

      def rebuild!
        initialize_cache if @cache.nil?

        @cache.each_pair do |result, sources|
          begin
            register_secretary sources
            write_sprocket result
          rescue ResolveError
            @cache.delete result
          end
        end
      end

      def paste_with_cache *sprockets
        initialize_cache if @cache.nil?
        
        if @cache[sprocket_name(sprockets)] != sprockets
          @cache[sprocket_name(sprockets)] = sprockets
          write_cache_to_disk
        end
        paste_without_cache *sprockets
      end

      protected
      
      def write_cache_to_disk
        file = tmp_path config.cache_file
        FileUtils.mkdir_p File.dirname(file)
        File.open(file, 'w') do |f|
          f << YAML.dump(@cache)
        end
      end

      def initialize_cache
        @cache = (YAML.load_file tmp_path(config.cache_file) rescue {})
      end
    end
  end
end
