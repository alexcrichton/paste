require 'active_support/core_ext/hash/reverse_merge'

module Paste
  module JS
    module Compress
      extend ActiveSupport::Concern
      
      included do
        alias_method_chain :rebuild!, :compression
      end

      def rebuild_with_compression! options = {}
        rebuild_without_compression!

        secretaries.keys.each do |sprocket|
          compress sprocket, options
        end
      end

      def compress sprocket, options = {}
        case options[:compress]
          when 'google'
            google_compress sprocket, options
          when nil, false
            # Compression not asked for
          else
            raise "Unknown compression technique: #{options[:compress]}"
        end
      end

      protected

      def google_compress sprocket, options = {}
        file = destination sprocket
        uri  = URI.parse('http://closure-compiler.appspot.com/compile')
        req  = Net::HTTP.post_form(uri,
          :js_code           => File.read(file),
          :compilation_level => options[:level] || 'SIMPLE_OPTIMIZATIONS', 
          :output_format     => 'text', 
          :output_info       => 'compiled_code'
        )

        if req.is_a? Net::HTTPSuccess
          File.open(file, 'w') { |f| f << req.body.chomp }
        else
          raise "Google couldn't compile #{sprocket}!"
        end

      end

    end
  end
end