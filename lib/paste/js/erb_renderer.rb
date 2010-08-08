require 'erb'

module Paste
  module JS
    module ERBRenderer

      def render_all_erb
        erb_sources.each { |s| render_erb s }
      end

      def render_erb source
        to_generate = erb_path source.sub(/\.erb$/, '')
        source      = find source

        if !File.exists?(to_generate) || 
            File.mtime(source) > File.mtime(to_generate)

          FileUtils.mkdir_p File.dirname(to_generate)
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
