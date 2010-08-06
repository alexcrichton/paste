module Paste

  class ResolveError < StandardError; end

  module Resolver

    def resolve path
      if File.exists?(path) || path.bytes.first == ?/
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
      config.load_path.map { |p| resolve p } + [erb_path]
    end 

    def find source
      source += '.js' unless source.end_with?('.js') || source.end_with?('.erb')

      result = environment.find(source).to_s
      raise ResolveError, "Source #{source} couldn't be found!" if result.blank?
      result
    end

    def environment
      @environment ||= Sprockets::Environment.new root, load_path
    end

    protected

    def join path1, path2
      if path2.blank?
        path1
      else
        File.join path1, path2
      end
    end
  end
end
