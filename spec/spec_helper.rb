require 'fileutils'
require 'rspec/core'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'sprockets-packager'

tmp_dir = File.expand_path('../tmp', __FILE__)

options = {
  :cache_dir   => tmp_dir + '/cache',
  :destination => tmp_dir + '/destination',
  :load_path   => [tmp_dir + '/sources']
}
Sprockets::Packager.options.merge!(options)

RSpec.configure do |c|
  c.color_enabled = true

  c.before(:each) do
    options[:load_path].each { |p| FileUtils.mkdir_p p }
  end
  
  c.after(:each) do
    FileUtils.rm_rf tmp_dir
  end
end


def dump_tree
  tmp_dir = File.dirname(Sprockets::Packager.options[:cache_dir])
  raise Dir[tmp_dir + '/**/*'].join("\n")
end