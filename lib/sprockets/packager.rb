require 'fileutils'
require 'pathname'
require 'digest/sha1'
require 'sprockets'

require 'sprockets/packager/watcher'

module Sprockets
  module Packager

    def self.options
      @@configuration ||= {
        :load_path       => ['app/javascripts'],
        :destination     => 'public/javascripts',
        :root            => ::Pathname.new('.'),
        :tmp_path        => 'tmp/sprockets-cache',
        :watch_changes   => false,
        :expand_includes => false,
        :serve_assets    => false
      }
    end

    def self.watcher
      @@watcher ||= Watcher.new options
    end
    
    def self.reset!
      @@watcher = nil
    end

  end
end

