module Sprockets
  module Packager
    module Cache      
      CACHE_FILE = 'sprockets.yml'
      
      def rebuild_cached_sprockets! options = {}
        initialize_cache if @sprockets_cache.nil?
        
        prepare!
        @sprockets_cache.values.each { |sprockets|
          result = sprocketize sprockets

          if options[:compress] == 'google'
            result.each do |sprocket|
              begin
                google_compress sprocket
              rescue => e
                puts "Error compressing: #{e}"
              end
            end
          end
        }
      end

      def update_sprockets_cache_file! sprocket, sources
        initialize_cache if @sprockets_cache.nil?

        if @sprockets_cache[sprocket] != sources
          @sprockets_cache[sprocket] = sources

          File.open(tmp_path.join(CACHE_FILE), 'w') do |f|
            f << YAML.dump(@sprockets_cache)
          end
        end
      end
      
      protected
      
      def initialize_cache
        @sprockets_cache = (YAML.load_file tmp_path.join(CACHE_FILE) rescue {})
      end
    end
  end
end