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
      self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{attribute} relative = ''
          if relative.blank?
            resolve config.#{attribute}
          else
            File.join resolve(config.#{attribute}), relative
          end
        end
      RUBY
    end

    def load_path
      config.load_path.map { |p| resolve p }
    end 

    def find source
      source += '.js' unless source.end_with?('.js') || source.end_with?('.erb')

      path = (load_path + ['']).detect do |path|
        File.exists? File.join(path, source)
      end

      raise ResolveError, "Source #{source} couldn't be found!" if path.nil?

      File.join(path, source)
    end

  end
end
