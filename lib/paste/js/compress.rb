require 'closure-compiler'
require 'active_support/core_ext/hash/except'

module Paste
  module JS
    module Compress
      extend ActiveSupport::Concern

      included do
        alias_method_chain :rebuild!, :compression
      end

      def rebuild_with_compression! options = {}
        rebuild_without_compression!

        results.keys.each do |result|
          compress result, options
        end
      end

      def compress result, options = {}
        case options[:compress]
          when 'google'
            google_compress result, options.except(:compress)
          when nil, false
            # Compression not asked for
          else
            raise "Unknown compression technique: #{options[:compress]}"
        end
      end

      protected

      def google_compress result, options = {}
        file, output = destination(result), ''
        handle = File.open(file, 'a+')
        File.open(file, 'r') do |f|
          output = Closure::Compiler.new(options).compile f
        end
        
        File.open(file, 'w+') { |f| f << output.chomp }
      end

    end
  end
end