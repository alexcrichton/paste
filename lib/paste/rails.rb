require 'active_support/core_ext/module/attr_accessor_with_default'

module Paste
  module Rails
    autoload :Helper,  'paste/rails/helper'
    autoload :Railtie, 'paste/rails/railtie'
    autoload :Updater, 'paste/rails/updater'

    class << self
      attr_accessor_with_default :glue do
        Paste::Glue.new
      end
    end
  end
end
