module Sprockets
  module Packager
    class Watcher
      CACHE_FILE = 'sprockets.yml'
      
      attr_reader :tmp_path, :erb_path, :secretary_config
      attr_accessor :watch_changes, :destination

      def initialize options = {}
        @options            = Sprockets::Packager.options.merge(options)
        @secretaries        = {}
        unless @options[:root].is_a?(Pathname)
          @options[:root] = ::Pathname.new @options[:root]
        end
        
        @tmp_path       = @options[:root].join @options[:tmp_path]
        @erb_path       = @tmp_path.join('erb')
        @destination    = @options[:root].join @options[:destination]
        @watch_changes  = @options[:watch_changes]

        @options[:load_path] << erb_path.to_s
        @options[:load_path] = @options[:load_path].map do |path|
          path = @options[:root].join(path).to_s if !File.directory?(path)
          path = ::Pathname.new(path)
          path.mkpath
          path.realpath
        end

        @secretary_config = {
            :root         => @options[:root].to_s, 
            :expand_paths => false,
            :load_path    => @options[:load_path].map(&:to_s)
        }
        
        @sprockets_cache = (YAML.load_file tmp_path.join(CACHE_FILE) rescue {})
      end

      def prepare!
        destination.mkpath
        erb_path.mkpath
        render_erb
      end
      
      def rebuild_cached_sprockets!
        @sprockets_cache.values.each { |sprockets| sprocketize sprockets }
      end

      def sprocketize *sprockets
        sprockets.flatten!
        return [] if sprockets.empty?

        if @options[:expand_includes]
          expand sprockets
        else
          compact sprockets
        end
      end

      def update_sprockets
        Dir[destination.to_s + '/**/*.js'].each do |sprocket_file|
          update_sprocket sprocket_file.gsub(destination.to_s + '/', '')
        end
      end

      def update_sprocket sprocket
        path      = destination.join(sprocket)
        secretary = @secretaries[sprocket]
        return false if secretary.nil?

        if changed? path, secretary.source_last_modified
          path.dirname.mkpath
          secretary.reset!
          secretary.concatenation.save_to path
        end
      end

      def render_erb
        # Look for .js.erb file in each of the load paths and 
        # regenerate if necessary
        @options[:load_path].each do |path|
          ::Pathname.glob(path.to_s + '/**/*.js.erb').each do |erb|
            relative  = erb.relative_path_from(path).sub(/\.erb$/, '')
            generated = erb_path.join relative
            generated.dirname.mkpath

            if changed? generated, erb.mtime
              contents = ERBHelper.new(erb.read).result
              generated.open('w') { |f| f << contents }
            end
          end
        end
      end

      protected

      def expand sprockets
        # Grab a secretary to generate dependency list for us
        name         = compact_sprocket_name(sprockets)
        if watch_changes
          secretary = register_secretary(name, sprockets)
        else
          secretary = @secretaries[name] || register_secretary(name, sprockets)
        end
        source_files = secretary.concatenation.source_lines.map(&:source_file)
        source_files = source_files.uniq.map{ |f| f.pathname.to_s }
        
        # Now take that list and copy the right file over
        source_files.map do |file|
          prefix   = @options[:load_path].detect{ |path| 
            file.start_with? path.to_s
          }
          sprocket = file.gsub prefix.to_s + '/', ''
          path     = destination.join(sprocket)

          if changed? path, File.mtime(file)
            path.dirname.mkpath
            FileUtils.cp file, path.to_s
          end

          sprocket
        end
      end
      
      def compact sprockets
        sprocket      = compact_sprocket_name sprockets
        sprocket_file = destination.join sprocket
        register_secretary sprocket, sprockets if @secretaries[sprocket].nil?

        if !sprocket_file.exist? || watch_changes
          update_sprocket sprocket
        end

        [sprocket]
      end
      
      def register_secretary sprocket, source_sprockets
        update_sprockets_cache_file! sprocket, source_sprockets
        config = secretary_config.dup
        environment = Sprockets::Environment.new config[:root],
                                                 config[:load_path]

        config[:source_files] = source_sprockets.map do |source_sprocket|
          source_sprocket += '.js' unless source_sprocket.end_with? '.js'
          environment.find(source_sprocket).to_s
        end

        @secretaries[sprocket] = Sprockets::Secretary.new config
      end

      def update_sprockets_cache_file! sprocket, sources
        if @sprockets_cache[sprocket] != sources
          @sprockets_cache[sprocket] = sources

          File.open(tmp_path.join(CACHE_FILE), 'w') do |f|
            f << YAML.dump(@sprockets_cache)
          end
        end
      end

      def changed? path, last_mod_time
        !path.exist? || path.mtime < last_mod_time
      end

      def compact_sprocket_name sprockets
        Digest::SHA1.hexdigest(sprockets.sort.join)[0..8] + '.js'
      end
    end
  end
end
