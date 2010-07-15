require 'fileutils'
require 'pathname'
require 'erb'
require 'digest/sha1'

require 'sprockets'
require 'sprockets/packager'
require 'sprockets/packager/helper'
require 'sprockets/packager/watcher'
require 'sprockets/packager/erb_helper'

module Sprockets
  module Packager

    def self.options
      @@configuration ||= {
        :load_path       => ['app/javascripts'],
        :destination     => 'public/javascripts',
        :root            => ::Pathname.new('.'),
        :tmp_path        => 'tmp/sprockets-cache',
        :watch_changes   => false,
        :expand_includes => false
      }
    end

    def self.watcher
      @@watcher ||= Watcher.new options
    end

  end
end

