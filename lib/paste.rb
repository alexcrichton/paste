require 'active_support/concern'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/module/attr_accessor_with_default'
require 'active_support/core_ext/module/delegation'

module Paste
  VERSION = '0.0.1'
  
  autoload :Glue,        'paste/glue'
  autoload :NeedsUpdate, 'paste/needs_update'
  autoload :Rails,       'paste/rails'
  autoload :Resolver,    'paste/resolver'

  module JS
    autoload :Base,        'paste/js/base'
    autoload :Cache,       'paste/js/cache'
    autoload :Chain,       'paste/js/chain'
    autoload :Compress,    'paste/js/compress'
    autoload :ERBRenderer, 'paste/js/erb_renderer'
    autoload :Unify,       'paste/js/unify'

    class << self
      delegate :configure, :config, :to => Base
    end
  end
  
  module CSS
    autoload :Base, 'paste/css/base'

    class << self
      delegate :configure, :config, :to => Base
    end
  end

  module Parser
    autoload :Sprockets, 'paste/parser/sprockets'
  end
end

Paste::Glue.configure do |config|
  config.root        = Dir.pwd
  config.tmp_path    = 'tmp/paste-cache'
end

Paste::JS.configure do |config|
  config.destination = 'public/javascripts'
  config.load_path   = ['app/javascripts']
  config.erb_path    = 'tmp/paste-cache/erb'
  config.cache_file  = 'sprockets.yml'
  config.parser      = Paste::Parser::Sprockets
end

Paste::CSS.configure do |config|
  config.destination = 'public/stylesheets'
  config.load_path   = ['app/stylesheets']
end

require 'paste/rails/railtie' if defined?(Rails)
