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
        in_order_traversal parser(source), js_dependencies, css_dependencies
      end

      {:javascripts => js_dependencies, :stylesheets => css_dependencies.uniq}
    end

    protected

    def in_order_traversal parser, js_deps, css_deps, current_path = []
      return if js_deps.include? parser.source

      if current_path.include? parser.source
        raise "Circular dependency at #{parser.source}"
      end

      current_path.push parser.source

      parser.js_dependencies.each do |dependency|
        in_order_traversal parser(dependency), js_deps, css_deps, current_path
      end

      js_deps.push current_path.pop

      parser.css_dependencies.each do |css_dep|
        css_deps.push css_dep
      end
    end

  end
end
