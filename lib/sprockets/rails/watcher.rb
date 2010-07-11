module Sprockets
  module Rails
    class Watcher
      
      def initialize options = Sprockets::Rails.options
        @options     = options
        @secretaries = {}
      end

      def prepare!
        create_directories
        render_erb
      end

      def sprocketize sprockets
        return if sprockets.blank?

        to_hash = sprockets.sort.join
        file    = Digest::SHA1.hexdigest(to_hash)[0..8] + '.js'

        cache_dir = ::Rails.root.join(@options[:cache_dir])

        if !File.exists? cache_dir.join(file)
          File.open(cache_dir.join(file), 'w') do |f|
            f << sprockets.map { |s| 
              "//= require <#{s}>"
            }.join("\n")
          end
        end
        
        sprocket_file = asset_location.join file
        if !File.exists?(sprocket_file) || Rails.options[:watch_changes]
          update_sprocket file
        end

        "/#{@options[:destination]}/#{file}"
      end

      def update_sprockets
        config = {:root => ::Rails.root}.merge(
                      @options.slice(:load_path, :asset_root))
        config[:load_path] << erb_path.to_s

        Dir[cache_dir.to_s + '/*.js'].each do |source|
          update_sprocket source, config
        end
      end
      
      def update_sprocket sprocket_or_file, config = nil
        if config.nil?
          config = {:root => ::Rails.root}.merge(
                        @options.slice(:load_path, :asset_root))
          config[:load_path] << erb_path.to_s
        end
  
        sprocket              = File.basename(sprocket_or_file)  
        path                  = asset_location.join(sprocket).to_s
        source                = cache_dir.join(sprocket).to_s
        config[:source_files] = [source]

        if @secretaries[path].nil?
          begin
            @secretaries[path] = Sprockets::Secretary.new config
          rescue Sprockets::LoadError => e
            @secretaries[path] = nil
            File.delete(path)   if File.exists?(path)
            File.delete(source) if File.exists?(source)
            
            ::Rails.logger.warn "WARNING: Sprockets Error: #{e}"
            return
          end
        end

        changed? path, @secretaries[path].source_last_modified do
          @secretaries[path].reset!
          @secretaries[path].concatenation.save_to path
        end
      end
      
      protected
      
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
      
      class ERBHelper < ERB
        include ActionView::Helpers

        def config
          ::Rails.application.config.action_controller
        end
        
        def result *args
          super binding
        end
      
        def controller
          nil
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

      def asset_location
        ::Rails.root.join @options[:asset_root], 
                          @options[:destination]
      end
      
      def erb_path
        cache_dir.join('erb')
      end

      def cache_dir
        ::Rails.root.join @options[:cache_dir]
      end
      
    end
  end
end
