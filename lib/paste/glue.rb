require 'active_support/configurable'

module Paste
  class Glue
    extend Resolver

    include ActiveSupport::Configurable
    include Resolver
    include JS::ERBRenderer
    
  end
end