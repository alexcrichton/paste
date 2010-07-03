module Sprockets
  module Rails
    
    def self.check_for_updates
      watcher.prepare!
      watcher.update_sprockets
    end

    def self.options
      @@configuration ||= {
        :load_path   => ['app/javascripts'],
        :asset_root  => 'public',
        :destination => 'javascripts/sprockets',
        :cache_dir   => 'tmp/sprockets-cache', 
      }
    end
    
    def self.watcher
      @@watcher = Watcher.new options
    end

  end
end

