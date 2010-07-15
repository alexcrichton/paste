require 'fileutils'
require 'pathname'
require 'erb'
require 'digest/sha1'

require 'sprockets'
require 'sprockets/packager'
require 'sprockets/packager/rack'
require 'sprockets/packager/helper'
require 'sprockets/packager/watcher'
require 'sprockets/packager/erb_helper'

module Sprockets
  module Packager

    def self.options
      @@configuration ||= {
        :load_path       => ['app/javascripts'],
        :destination     => 'public/javascripts',
        :root            => defined?(Rails) ? Rails.root : ::Pathname.new('.'),
        :cache_dir       => 'tmp/sprockets-cache',
        :watch_changes   => defined?(Rails) && Rails.env.development?,
        :expand_includes => defined?(Rails) && Rails.env.development?
      }
    end

    def self.watcher
      @@watcher ||= Watcher.new options
    end

  end
end

