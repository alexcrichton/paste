require 'closure-compiler'
require 'active_support/core_ext/hash/except'

module Paste
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

    def has_java?
      system 'java &> /dev/null'
    end

    def google_compress *args
      has_java? ? google_compress_with_java(*args) :
        google_compress_without_java(*args)
    end

    def google_compress_with_java result, options = {}
      file, output = destination(result), ''
      handle = File.open(file, 'a+')
      File.open(file, 'r') do |f|
        output = Closure::Compiler.new(options).compile f
      end

      File.open(file, 'w+') { |f| f << output.chomp }
    end

    def google_compress_without_java result, options = {}
      file = destination result
      uri  = URI.parse('http://closure-compiler.appspot.com/compile')
      req  = Net::HTTP.post_form(uri,
        :js_code           => File.read(file),
        :compilation_level => options[:compilation_level] ||
          'SIMPLE_OPTIMIZATIONS',
        :output_format     => 'text',
        :output_info       => 'compiled_code'
      )

      if req.is_a? Net::HTTPSuccess
        File.open(file, 'w') { |f| f << req.body.chomp }
      else
        raise "Google couldn't compile #{result}!"
      end
    end

  end
end
