module Paste
  module JS
    class Base < Glue

      include Cache
      include Compress

      def paste *sources
        raise 'Implement me!'
      end

      def result_name sources
        raise 'Implement me!'
      end

      def write_result result
        raise 'Implement me!'
      end

    end
  end
end
