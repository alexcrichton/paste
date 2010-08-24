require 'active_support/core_ext/module/synchronization'

require 'yaml'

module Paste
  module JS
    module Cache

      def rebuild
        rebuild_if do |result, sources|
          needs_update? result
        end
      end

      def rebuild!
        rebuild_if { |r, s| true }
      end

      def rebuild_if &blk
        render_all_erb
        results.each_pair do |result, sources|
          begin
            if blk.call(result, sources[:sources])
              sources[:parser].reset!
              write_result result
            end
          rescue ResolveError
            results.delete result
          end
        end
      end

      def register sources, into_hash = nil
        into_hash ||= results

        if into_hash[result_name(sources)][:sources] != sources
          into_hash[result_name(sources)] = {
            :sources => sources,
            :parser  => config.parser.new(self, sources)
          }

          write_cache_to_disk into_hash
        end
      end

      def registered? sources
        results.key? result_name(sources)
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
        return @results if defined?(@results)

        @results = Hash.new { {} }

        begin
          cached = YAML.load_file tmp_path(config.cache_file)

          if cached
            cached.each do |sources|
              register sources, @results
            end
          end
        rescue
        end

        @results
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

      def write_cache_to_disk cache
        file = tmp_path config.cache_file
        FileUtils.mkdir_p File.dirname(file)

        to_write = []
        cache.each do |result, hash|
          to_write << hash[:sources]
        end

        File.open(file, 'w') do |f|
          f << YAML.dump(to_write)
        end
      end

    end
  end
end
