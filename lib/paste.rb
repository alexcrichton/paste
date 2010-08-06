require 'active_support/concern'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/module/attr_accessor_with_default'

module Paste

  VERSION = '0.0.1'
  
  autoload :Glue, 'paste/glue'
  autoload :NeedsUpdate, 'paste/needs_update'
  autoload :Rails, 'paste/rails'
  autoload :Resolver, 'paste/resolver'

  module JS
    autoload :Base, 'paste/js/base'
    autoload :Cache, 'paste/js/cache'
    autoload :Chain, 'paste/js/chain'
    autoload :Compress, 'paste/js/compress'
    autoload :ERBRenderer, 'paste/js/erb_renderer'
    autoload :Sprockets, 'paste/js/sprockets'
    autoload :Unify, 'paste/js/unify'

    def self.configure &blk
      Paste::JS::Base.configure &blk
    end

    def self.config
      Paste::JS::Base.config
    end

    module Parser
      autoload :Sprockets, 'paste/js/parser/sprockets'
    end
  end
end

Paste::JS.configure do |config|
  config.root        = Dir.pwd
  config.destination = 'public/javascripts'
  config.tmp_path    = 'tmp'
  config.erb_path    = 'tmp/erb'
  config.cache_file  = 'sprockets.yml'
  config.parser      = Paste::JS::Parser::Sprockets
end

require 'paste/rails/railtie' if defined?(Rails)
