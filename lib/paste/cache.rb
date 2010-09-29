require 'active_support/core_ext/module/synchronization'
require 'yaml'

module Paste
  module Cache

    def rebuild
      load_path.each do |path|
        Dir[path + '/**/*.js'].each do |file|
          relative = file.gsub path + '/', ''

          if needs_update? relative
            result = File.join destination, relative
            FileUtils.mkdir_p File.dirname(result)
            FileUtils.cp file, result
          end
        end
      end
    end

    def register source, into_hash = nil
      into_hash ||= results

      into_hash[source] ||= {
        :source  => source,
        :parser  => config.parser.new(self, source)
      }
    end

    def registered? source
      results.key? source
    end

    def needs_update? result
      needs_update_relative_to_sources result do
        results[result][:sources]
      end
    end

    def needs_dependency_update? result
      needs_update_relative_to_sources result do
        results[result][:parser].js_dependencies
      end
    end

    def results
      @results ||= {}
    end

    @@results_lock = Mutex.new
    synchronize :results, :with => :@@results_lock

    protected

    def needs_update_relative_to_sources result
      path = destination result
      return true unless File.exists?(path) && results.key?(result)

      yield.inject(false) do |prev, source|
        prev || File.mtime(path) < File.mtime(find(source))
      end
    end

  end
end
