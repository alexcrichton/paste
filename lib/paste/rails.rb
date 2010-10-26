module Paste
  module Rails
    autoload :Helper,  'paste/rails/helper'
    autoload :Railtie, 'paste/rails/railtie'
    autoload :Updater, 'paste/rails/updater'

    mattr_accessor :glue

    self.glue = Paste::Glue.new
  end
end
