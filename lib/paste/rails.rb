require 'active_support/core_ext/module/attr_accessor_with_default'

module Paste
  module Rails
    autoload :Railtie, 'paste/rails/ralitie'
    autoload :Helper, 'paste/rails/helper'
    
    class << self
      attr_accessor_with_default :glue, Paste::JS::Unify.new
    end
  end
end