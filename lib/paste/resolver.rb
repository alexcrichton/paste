require 'active_support/core_ext/object/blank'

module Paste

  class ResolveError < StandardError; end

  module Resolver

    def resolve path
      if Pathname.new(path).absolute?
        File.expand_path path
      else
        File.join config.root, path
      end
    end

    [:destination, :root, :erb_path, :tmp_path].each do |attribute|
      config_attribute = attribute == :destination ? :js_destination : attribute
      self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{attribute} relative = ''
          if relative.blank?
            resolve config.#{config_attribute}
          else
            File.join resolve(config.#{config_attribute}), relative
          end
        end
      RUBY
    end

    def load_path
      config.js_load_path.map { |p| resolve p }
    end

    def find source
      source += '.js' unless source.end_with?('.js') || source.end_with?('.erb')

      path = (load_path + ['']).detect do |root|
        File.exists? File.join(root, source)
      end

      raise ResolveError, "Source #{source} couldn't be found!" if path.nil?

      File.join(path, source)
    end

  end
end
