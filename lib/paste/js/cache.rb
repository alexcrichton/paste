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
            write_result result if blk.call(result, sources[:sources])
          rescue ResolveError
            results.delete result
          end
        end
      end

      def register sources
        if results[result_name(sources)][:sources] != sources
          results[result_name(sources)] = {
            :sources => sources,
            :parser  => config.parser.new(self, sources)
          }

          write_cache_to_disk
        end
      end

      def registered? sources
        results.key? result_name(sources)
      end

      def needs_update? result
        path = destination result
        return true unless File.exists?(path) && results.key?(result)

        results[result][:sources].inject(false) do |prev, source|
          prev || File.mtime(path) < File.mtime(find(source))
        end
      end

      def results
        return @results if defined?(@results)
        @results = Hash.new { {} }

        begin
          cached = YAML.load_file tmp_path(config.cache_file)
        rescue
          cached = []
        end

        cached.each do |sources|
          register sources
        end

        @results
      end

      protected

      def write_cache_to_disk
        file = tmp_path config.cache_file
        FileUtils.mkdir_p File.dirname(file)

        to_write = []
        results.each do |result, hash|
          to_write << hash[:sources]
        end

        File.open(file, 'w') do |f|
          f << YAML.dump(to_write)
        end
      end

    end
  end
end
