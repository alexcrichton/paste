module Sprockets
  module Packager

    def self.options
      @@configuration ||= {
        :load_path       => ['app/javascripts'],
        :asset_root      => 'public',
        :javascript_dir  => 'javascripts',
        :cache_dir       => 'tmp/sprockets-cache',
        :watch_changes   => Rails.env.development?,
        :expand_includes => Rails.env.development?
      }
    end

    def self.watcher
      @@watcher ||= Watcher.new options
    end

  end
end

