module Paste
  module Cache

    def rebuild
      find_sources

      @sources.reject!{ |_, parser| !File.exists? parser.file }

      @sources.values.each{ |v| v.copy_if_needed }
    end

    def parser source
      find_sources if @sources.nil?
      @sources[find(source)]
    end

    protected

    def find_sources
      @sources ||= {}

      load_path.each do |path|
        Dir[path + '/**/*.js'].each do |file|
          @sources[file] ||= config.parser.new(self, file.gsub(path + '/', ''))
        end
      end
    end

  end
end
