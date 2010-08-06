def dump_tree
  raise Dir[Paste::JS::Base.root + '/**/*'].map { |f|
    unless File.directory?(f)
      out = f
      out += "\n\t- " + File.read(f).gsub("\n", "\n\t- ")
      out += "\n\t\t(#{File.mtime(f)})"
      f = out
    end
    f
  }.join("\n")
end

module Paste
  module Test
    class << self

      def write sprocket, contents, last_modified = Time.now
        file = path sprocket
        FileUtils.mkdir_p File.dirname(file)
        File.open(file, 'w') { |f| f << contents }

        touch sprocket, last_modified
      end

      def touch sprocket, modified_time = Time.now
        File.utime Time.now, modified_time, path(sprocket)
      end

      def path sprocket
        return sprocket if sprocket.to_s[0...1] == '/'

        file = File.join(Paste::JS::Base.load_path.first, sprocket)
        file += '.js' unless file.end_with?('.js') || file.end_with?('.erb')
        file
      end

      def delete sprocket
        file = File.join(Paste::JS::Base.destination, sprocket)
        file += '.js' unless file.end_with?('.js')

        File.delete(file)
      end

      def delete_source source
        file = File.join(Paste::JS::Base.load_path.first, source)
        file += '.js' unless file.end_with?('.js')

        File.delete(file)
      end
    end
  end
end