module Sprockets
  module Packager
    module Version
      STRING = File.readlines(File.expand_path('../../../../VERSION', __FILE__)).first
    end
  end
end
