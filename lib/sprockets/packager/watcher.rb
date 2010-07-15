module Sprockets
  module Packager
    class Watcher
      
      attr_reader :cache_dir, :erb_path, :destination, :secretary_config
      
      def initialize options = {}
        @options            = Sprockets::Packager.options.merge(options)
        @secretaries        = {}
        unless @options[:root].is_a?(Pathname)
          @options[:root] = ::Pathname.new @options[:root]
        end

        @cache_dir      = @options[:root].join @options[:cache_dir]
        @erb_path       = @cache_dir.join('erb')
        @destination    = @options[:root].join @options[:destination]

        @options[:load_path] += [erb_path.to_s, cache_dir.to_s]
        @secretary_config = {
            :root         => @options[:root], 
            :expand_paths => false,
            :load_path    => @options[:load_path]
        }
      end

      def prepare!
        create_directories
        render_erb
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
        Dir[cache_dir.to_s + '/**/*.js'].each do |source|
          update_sprocket source
        end
      end

      def update_sprocket sprocket, dependencies = []
        path      = destination.join(sprocket).to_s
        secretary = get_secretary sprocket, :source_files => dependencies
        return false if secretary.nil?

        changed? path, secretary.source_last_modified do
          FileUtils.mkdir_p destination unless File.directory?(destination)
          secretary.reset!
          secretary.concatenation.save_to path
        end
      end

      def render_erb
        # Look for .js.erb file in each of the load paths and 
        # regenerate if necessary
        @options[:load_path].each do |path|
          Dir[path + '/**/*.js.erb'].each do |erb_file|
            relative_path = erb_file.gsub(path + '/', '').
                                     gsub(/\.erb$/, '')
            generated     = erb_path + relative_path

            FileUtils.mkdir_p File.dirname(generated)

            changed? generated, File.mtime(erb_file) do
              contents = ERBHelper.new(File.read(erb_file)).result
              File.open(generated, 'w') { |f| f << contents }
            end
          end
        end
      end

      protected
      
      def expand sprockets
        secretary    = get_secretary compact_sprocket_name(sprockets), :source_files => sprockets
        source_files = secretary.concatenation.source_lines.map(&:source_file)
        source_files = source_files.uniq.map(&:pathname).map(&:to_s)

        source_files.map do |file|
          prefix   = @options[:load_path].detect{ |path| file.start_with? path }
          sprocket = file.gsub prefix + '/', ''
          path     = destination.join(sprocket)

          changed? path, File.mtime(file) do
            FileUtils.mkdir_p File.dirname(path)
            FileUtils.cp file, path
          end

          sprocket
        end
      end
      
      def compact sprockets
        sprocket = compact_sprocket_name sprockets

        if Packager.options[:watch_changes]
          write_temp_sprocket_file sprocket, sprockets
        end

        sprocket_file = destination.join sprocket

        if !File.exists?(sprocket_file) || Packager.options[:watch_changes]
          update_sprocket sprocket, sprockets
        end

        [sprocket]
      end
      
      def get_secretary sprocket, options = {}
        if @secretaries[sprocket].nil?
          config = options.merge secretary_config
          if config[:source_files].empty?
            @environment = Sprockets::Environment.new config[:root],
                                                      config[:load_path]
            config[:source_files]  = [@environment.find(sprocket).to_s]
          end
          
          config[:source_files].each { |f| f << '.js' unless f.end_with? '.js' }

          @secretaries[sprocket] = Sprockets::Secretary.new config
        end

        @secretaries[sprocket]
      end

      def create_directories
        FileUtils.mkdir_p cache_dir
        FileUtils.mkdir_p destination
        FileUtils.mkdir_p erb_path
      end
      
      def changed? file, last_mod_time
        if !File.exists?(file) || File.mtime(file) < last_mod_time
          yield
        end
      end

      def compact_sprocket_name sprockets
        Digest::SHA1.hexdigest(sprockets.sort.join)[0..8] + '.js'
      end
      
      def write_temp_sprocket_file sprocket, sprockets
        file = cache_dir.join(sprocket)
        return if File.exists? cache_dir.join(sprocket)

        File.open(file, 'w') do |f|
          f << sprockets.map { |s| 
            "//= require <#{s}>"
          }.join("\n")
        end
      end
    end
  end
end
