module Paste
  module NeedsUpdate
    
    def needs_update? file, last_modified_time
      !File.file?(file) || File.mtime(file) < last_modified_time
    end
    
  end
end