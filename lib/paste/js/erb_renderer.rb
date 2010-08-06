module Paste
  module JS
    module ERBRenderer

      def render_all_erb
        load_path.each do |path|
          Dir[path + '/**/*.js.erb'].each do |erb|
            render_erb erb.gsub(path + '/', '')
          end
        end
      end

      def render_erb source
        relative    = source.sub(/\.erb$/, '')
        to_generate = erb_path relative
        source      = find source

        if !File.existsneeds_update? to_generate, File.mtime(source)
          FileUtils.mkdir_p File.dirname(to_generate)
          contents = Helper.new(File.read(source)).result
          File.open(to_generate, 'w') { |f| f << contents }
        end
      end

      def render_erb_if source, &block
        
      end

      class Helper < ERB
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

    end
  end
end
