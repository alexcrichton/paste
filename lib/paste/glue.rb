require 'active_support/configurable'

module Paste
  class Glue
    extend Resolver

    include ActiveSupport::Configurable
    include Resolver
    include ERBRenderer
    include Cache

    def initialize
      config.js_load_path << erb_path
    end

    def paste *sources
      js_dependencies  = []
      css_dependencies = []

      sources.each do |source|
        source << '.js' unless source.end_with? '.js'

        if registered? source
          if needs_update?(source) || needs_dependency_update?(source)
            results[source][:parser].reset!
          end
        else
          register source
        end

        source_deps  = results[source][:parser].js_dependencies
        source_deps.each{ |s| s << '.js' unless s.end_with? '.js' }
        js_dependencies = source_deps | js_dependencies
      end

      js_dependencies.each do |dep|
        dep << '.js' unless dep.end_with? '.js'
        register dep unless registered? dep # implicit dependencies

        css_dependencies = css_dependencies |
            results[dep][:parser].css_dependencies

        dep
      end

      {
        :javascripts => js_dependencies,
        :stylesheets => css_dependencies
      }
    end

  end
end
