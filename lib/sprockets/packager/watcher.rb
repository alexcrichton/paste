module Sprockets
  module Packager
    class Watcher
      
      attr_reader :tmp_path, :erb_path, :destination, :secretary_config
      attr_accessor :watch_changes
      
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
        @secretary_config = {
            :root         => @options[:root], 
            :expand_paths => true,
            :load_path    => @options[:load_path]
        }
      end

      def prepare!
        FileUtils.mkdir_p destination
        FileUtils.mkdir_p erb_path
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
        Dir[destination.to_s + '/**/*.js'].each do |sprocket_file|
          update_sprocket sprocket_file.gsub(destination.to_s + '/', '')
        end
      end

      def update_sprocket sprocket
        path      = destination.join(sprocket).to_s
        secretary = @secretaries[sprocket]
        return false if secretary.nil?

        if changed? path, secretary.source_last_modified
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

            if changed? generated, File.mtime(erb_file)
              contents = ERBHelper.new(File.read(erb_file)).result
              File.open(generated, 'w') { |f| f << contents }
            end
          end
        end
      end

      protected

      def expand sprockets
        # Grab a secretary to generate dependency list for us
        name         = compact_sprocket_name(sprockets)
        secretary    = @secretaries[name] || register_secretary(name, sprockets)
        source_files = secretary.concatenation.source_lines.map(&:source_file)
        source_files = source_files.uniq.map{ |f| f.pathname.to_s }
        
        # Now take that list and copy the right file over
        source_files.map do |file|
          prefix   = @options[:load_path].detect{ |path| file.start_with? path }
          sprocket = file.gsub prefix + '/', ''
          path     = destination.join(sprocket)

          if changed? path, File.mtime(file)
            FileUtils.mkdir_p File.dirname(path)
            FileUtils.cp file, path
          end

          sprocket
        end
      end
      
      def compact sprockets
        sprocket      = compact_sprocket_name sprockets
        sprocket_file = destination.join sprocket
        
        register_secretary sprocket, sprockets if @secretaries[sprocket].nil?

        if !File.exists?(sprocket_file) || watch_changes
          update_sprocket sprocket
        end

        [sprocket]
      end
      
      def register_secretary sprocket, source_sprockets
        config = secretary_config.dup
        environment = Sprockets::Environment.new config[:root],
                                                 config[:load_path]
        config[:source_files] = source_sprockets.map do |sprocket|
          sprocket += '.js' unless sprocket.end_with? '.js'
          environment.find(sprocket).to_s
        end

        @secretaries[sprocket] = Sprockets::Secretary.new config
      end

      def changed? file, last_mod_time
        !File.exists?(file) || File.mtime(file) < last_mod_time
      end

      def compact_sprocket_name sprockets
        Digest::SHA1.hexdigest(sprockets.sort.join)[0..8] + '.js'
      end
    end
  end
end
