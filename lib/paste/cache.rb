require 'active_support/core_ext/module/synchronization'
require 'yaml'

module Paste
  module Cache

    def rebuild
      find_sources

      @sources.values.each &:copy_if_needed
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
