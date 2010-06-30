module Sprockets
  module Rails
    module Version
      STRING = File.readlines(File.expand_path('../../../../VERSION', __FILE__)).first
    end
  end
end
