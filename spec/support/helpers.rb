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

      def write source, contents, last_modified = Time.now
        file = path source
        FileUtils.mkdir_p File.dirname(file)
        File.open(file, 'w') { |f| f << contents }

        touch source, last_modified
      end

      def touch source, modified_time = Time.now
        File.utime Time.now, modified_time, path(source)
      end

      def path source
        return source if source.to_s[0...1] == '/'

        file = File.join(Paste::JS::Base.load_path.first, source)
        file += '.js' unless file.end_with?('.js') || file.end_with?('.erb')
        file
      end

      def delete result
        file = File.join(Paste::JS::Base.destination, result)
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