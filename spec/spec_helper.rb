require 'fileutils'
require 'rubygems'
require 'rspec/core'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'sprockets-packager'

tmp_dir = File.expand_path('../tmp', __FILE__)

options = {
  :root        => tmp_dir,
  :tmp_path    => 'temporary',
  :destination => 'destination',
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
  root = Sprockets::Packager.options[:root]

  raise Dir[root + '/**/*'].map { |f|
    unless File.directory?(f)
      out = f
      out += "\n\t- " + File.read(f).gsub("\n", "\n\t- ")
      out += "\n\t\t(#{File.mtime(f)})"
      f = out
    end
    f
  }.join("\n")
end
