require 'active_support/concern'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/module/attr_accessor_with_default'
require 'active_support/core_ext/module/delegation'

module Paste
  autoload :Cache,        'paste/cache'
  autoload :Compress,     'paste/compress'
  autoload :ERBRenderer,  'paste/erb_renderer'
  autoload :Glue,         'paste/glue'
  autoload :Rails,        'paste/rails'
  autoload :Resolver,     'paste/resolver'
  autoload :ResolveError, 'paste/resolver'
  autoload :VERSION,      'paste/version'

  class << self
    delegate :configure, :config, :to => Glue
  end

  module Parser
    autoload :Sprockets, 'paste/parser/sprockets'
  end
end

Paste.configure do |config|
  config.root        = Dir.pwd
  config.tmp_path    = 'tmp/paste-cache'

  config.js_destination = 'public/javascripts'
  config.js_load_path   = ['app/javascripts']
  config.erb_path       = 'tmp/paste-cache/erb'
  config.parser         = Paste::Parser::Sprockets
end

require 'paste/rails/railtie' if defined?(Rails)
