require 'active_support/configurable'

module Paste
  class Glue
    extend Resolver

    include ActiveSupport::Configurable
    include Resolver
    include ERBRenderer
    include Cache
    include Compress

    def initialize
      config.js_load_path << erb_path
    end

    def paste *sources
      js_dependencies  = []
      css_dependencies = []

      sources.each do |source|
        name = result_name [source]
        if registered? [source]
          if needs_update?(name) || needs_dependency_update?(name)
            results[name][:parser].reset!
          end
        else
          register [source]
        end

        source_deps  = results[name][:parser].js_dependencies
        js_dependencies = source_deps | js_dependencies
      end

      js_dependencies.map! do |d|
        result = result_name [d]
        register [d] unless registered? [d] # implicit dependencies
        write_result result if needs_update?(result)

        css_dependencies = css_dependencies |
            results[result][:parser].css_dependencies

        result
      end

      {
        :javascripts => js_dependencies,
        :stylesheets => css_dependencies
      }
    end

    def write_result result
      file = destination result

      FileUtils.mkdir_p File.dirname(file)
      FileUtils.cp find(result), file
    end

    def result_name sources
      result = sources.first
      result += '.js' unless result.end_with?('.js')
      result
    end

  end
end
