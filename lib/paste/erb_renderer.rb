require 'erb'

module Paste
  module ERBRenderer

    def render_all_erb
      # Remove all stale rendered ERB files if we can't find their original
      # source to prevent deleting the source file and having the rendered erb
      # file still available for use
      Dir[erb_path + '/**/*.js'].each do |erb|
        erb_rel = erb.gsub erb_path + '/', ''

        begin
          find(erb_rel + '.erb')
        rescue ResolveError
          File.delete erb
        end
      end

      erb_sources.each{ |s| render_erb s }
    end

    def render_erb source
      to_generate = erb_path source.sub(/\.erb$/, '')
      source      = find source

      if !File.exists?(to_generate) ||
          File.mtime(source) > File.mtime(to_generate)

        FileUtils.mkdir_p File.dirname(to_generate)
        # Generate the contents before we throw open the file so we don't create
        # empty files if an exception occurs somewhere
        contents = PasteERBHelper.new(File.read(source)).result
        File.open(to_generate, 'w') { |f| f << contents }
      end
    end

    protected

    def erb_sources
      sources = load_path.map do |path|
        Dir[path + '/**/*.js.erb'].map do |erb|
          erb.gsub(path + '/', '')
        end
      end
      sources.flatten
    end

  end
end

# This needs to be outside of the module because we don't want to
# force templates to always do ::Rails
class PasteERBHelper < ERB
  include ActionView::Helpers if defined?(ActionView::Helpers)

  def config
    Rails.application.config.action_controller if defined?(Rails)
  end

  def result *args
    super binding
  end

  def controller
    nil
  end
end
