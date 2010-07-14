module Sprockets
  module Packager
    class Watcher
      
      attr_accessor :cache_dir, :erb_path, :asset_location
      
      def initialize options = {}
        @options            = Sprockets::Packager.options.merge(options)
        @secretaries        = {}
        self.cache_dir      = Rails.root.join @options[:cache_dir]
        self.erb_path       = cache_dir.join('erb')
        self.asset_location = Rails.root.join @options[:asset_root], 
                                              @options[:javascript_dir]                                              

        @options[:load_path] += [erb_path.to_s, cache_dir.to_s]
        @options[:default_config] = {
            :root         => Rails.root, 
            :expand_paths => false
          }.merge(@options.slice(:load_path, :asset_root))
      end

      def prepare!
        create_directories
        render_erb
      end

      def sprocketize sprockets
        return [] if sprockets.blank?

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

      def update_sprocket sprocket
        path      = asset_location.join(sprocket).to_s
        secretary = get_secretary sprocket

        changed? path, secretary.source_last_modified do
          secretary.reset!
          secretary.concatenation.save_to path
        end
      end

      protected
      
      def expand sprockets
        secretary    = get_secretary get_file_name(sprockets)
        source_files = secretary.concatenation.source_lines.map(&:source_file)
        source_files = source_files.uniq.map(&:pathname).map(&:to_s)

        source_sprockets 

        source_files.each do |file|
          path = asset_location.join(file)
          changed? path, File.mtime(file) do
            FileUtils.mkdir_p path
            FileUtils.cp file, path
          end
        end
        
        source_files.map{ |s| s.gsub asset_location.to_s, '' }
      end
      
      def compact sprockets
        file = get_file_name sprockets

        if Packager.options[:watch_changes]
          write_temp_sprocket_file file, sprockets
        end

        sprocket_file = asset_location.join file

        if !File.exists?(sprocket_file) || Packager.options[:watch_changes]
          update_sprocket file
        end

        ["/#{@options[:javascript_dir]}/#{dep}"]
      end
      
      def get_secretary sprocket
        if @secretaries[sprocket].nil?
          begin
            config = @options[:default_config]
            @environment = Sprockets::Environment.new config[:root],
                                                      config[:load_path]
            config[:source_files]  = [@environment.find(sprocket).to_s]
            @secretaries[sprocket] = Sprockets::Secretary.new config
          rescue Sprockets::LoadError => e
            @secretaries[sprocket] = nil
            path = asset_location.join sprocket
            File.delete(path)   if File.exists?(path)

            Rails.logger.warn "WARNING: Sprockets Error: #{e}"
            return
          end
        end

        @secretaries[sprocket]
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

      def create_directories
        FileUtils.mkdir_p cache_dir
        FileUtils.mkdir_p asset_location
        FileUtils.mkdir_p erb_path
      end
      
      def changed? file, last_mod_time
        if !File.exists?(file) || File.mtime(file) < last_mod_time
          yield
        end
      end

      def get_file_name sprockets
        Digest::SHA1.hexdigest(sprockets.sort.join)[0..8] + '.js'
      end
      
      def write_temp_sprocket_file file, sprockets
        return if File.exists? cache_dir.join(file)

        File.open(cache_dir.join(file), 'w') do |f|
          f << sprockets.map { |s| 
            "//= require <#{s}>"
          }.join("\n")
        end
      end
    end
  end
end
