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

        "/#{@options[:destination]}/#{file}"
      end

      def update_sprockets

        config = {:root => ::Rails.root}.merge(
                      @options.slice(:load_path, :asset_root))
        config[:load_path] << erb_path.to_s

        Dir[cache_dir.to_s + '/*.js'].each do |source|
          config[:source_files] = [source]
          path = asset_location.join(File.basename(source)).to_s

          if @secretaries[path].nil?
            begin
              @secretaries[path] = Sprockets::Secretary.new config
            rescue Sprockets::LoadError => e
              @secretaries[path] = nil
              File.delete(path) if File.exists?(path)
              next
            end
          end

          changed? path, @secretaries[path].source_last_modified do
            @secretaries[path].reset!
            @secretaries[path].concatenation.save_to path
          end
        end
      end
      
      protected
      
      def render_erb
        # Look for .js.erb file in each of the load paths and 
        # regenerate if necessary
        @options[:load_path].each do |path|
          Dir[path + '/**/*.js.erb'].each do |erb_file|          
            generated = erb_path.join File.basename(erb_file, '.erb')

            FileUtils.mkdir_p File.dirname(generated)

            changed? generated, File.mtime(erb_file) do
              File.open(generated, 'w') do |f|
                f << ERB.new(File.read(erb_file)).result
              end
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
