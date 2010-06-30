require 'fileutils'
require 'digest/sha1'

module Sprockets
  module Rails
    
    def self.check_for_updates
      config = configuration.merge :root => ::Rails.root
      
      erb_path = cache_dir.join('erb')
      sprocket_location = ::Rails.root.join('public/javascripts/sprockets')
      
      FileUtils.mkdir_p erb_path, :mode => 0755
      FileUtils.mkdir_p sprocket_location, :mode => 0755
      
      config[:load_path].each do |path|
        Dir[path + '/**/*.js.erb'].each do |erb_file|          
          generated = erb_path.join File.basename(erb_file)
          generated = generated.to_s.gsub(/\.erb$/, '')
          
          FileUtils.mkdir_p File.dirname(generated), :mode => 0755
          
          changed? generated, File.mtime(erb_file) do
            puts "ERBifying #{erb_file}"

            File.open(generated, 'w') do |f|
              f << ERB.new(File.read(erb_file)).result
            end
          end
        end
      end
      
      config[:load_path] << erb_path.to_s

      Dir[cache_dir.to_s + '/*.js'].each do |source|
        config[:source_files] = [source]
        path = sprocket_location.join(File.basename(source)).to_s

        begin
          secretary = Sprockets::Secretary.new config
        rescue Sprockets::LoadError => e
          File.delete(path) if File.exists?(path)
          next
        end
        
        last_modified = secretary.source_last_modified
        
        changed? path, secretary.source_last_modified do
          puts "Regenerating: #{source}"

          secretary.concatenation.save_to path
        end
      end
    end
    
    def self.path_for_sources sources
      file = Digest::SHA1.hexdigest(sources.sort.join) + '.js'

      if !File.exists? File.join(cache_dir, file)
        FileUtils.mkdir_p cache_dir, :mode => 0755
        File.open(File.join(cache_dir, file), 'w') do |f|
          f << sources.map { |s| "//= require <#{s}>" }.join("\n")
        end
      end

      '/javascripts/sprockets/%s' % file
    end
    
    def self.cache_dir
      ::Rails.root.join('tmp', 'sprockets-cache')
    end

    protected

    def self.configuration
      YAML.load_file(::Rails.root.join("config", "sprockets.yml")) || {}
    end
    
    def self.changed? file, last_mod_time
      if !File.exists?(file) || File.mtime(file) < last_mod_time
        yield
      end
    end

  end
end

require 'sprockets/rails/helper'
require 'sprockets/rails/rack'

class ActionView::Base
  include Sprockets::Rails::Helper
end
