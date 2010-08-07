module Paste
  module Rails
    autoload :Railtie, 'paste/rails/ralitie'
    autoload :Helper, 'paste/rails/helper'
    
    class << self
      attr_accessor_with_default :glue do
        Paste::JS::Unify.new
      end
    end
  end
end