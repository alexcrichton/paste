def dump_tree
  root = Sprockets::Packager.options[:root]

  raise Dir[root + '/**/*'].map { |f|
    unless File.directory?(f)
      out = f
      out += "\n\t- " + File.read(f).gsub("\n", "\n\t- ")
      out += "\n\t\t(#{File.mtime(f)})"
      f = out
    end
    f
  }.join("\n")
end

def write_sprocket sprocket, contents, last_modified = Time.now
  file = sprocket_path(sprocket)
  FileUtils.mkdir_p File.dirname(file)
  File.open(file, 'w') { |f| f << contents }

  touch_sprocket sprocket, last_modified
end

def touch_sprocket sprocket, modified_time = Time.now
  File.utime Time.now, modified_time, sprocket_path(sprocket)
end

def sprocket_path sprocket
  return sprocket if sprocket.to_s[0...1] == '/'

  file = Sprockets::Packager.options[:load_path][0]
  file += '/' + sprocket
  file += '.js' unless file.end_with?('.js') || file.end_with?('.erb')
  file
end

def delete_generated sprocket
  file = Sprockets::Packager.options[:root]
  file += '/' + Sprockets::Packager.options[:destination]
  file += '/' + sprocket
  file += '.js' unless file.end_with?('.js')

  File.delete(file)
end
