require 'net/http'
require 'json'

module Sprockets
  module Packager
    module Compressor

      def google_compress sprocket
        file = destination.join sprocket
        uri  = URI.parse('http://closure-compiler.appspot.com/compile')
        body = Net::HTTP.post_form(uri, 
          :js_code           => file.read,
          :compilation_level => 'SIMPLE_OPTIMIZATIONS', 
          :output_format     => 'json', 
          :output_info       => 'compiled_code'
        )
        json = JSON.load(body.body)

        if json['compiledCode']
          file.open('w') { |f| f << json['compiledCode'] }
        else
          raise "Google couldn't compile #{sprocket}!"
        end
      end
      
    end
  end
end