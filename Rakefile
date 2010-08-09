require 'rubygems'
require 'bundler/setup'
require 'paste'

namespace :gem do
  desc "Build the gem"
  task :build do
    pkg_dir = File.dirname(__FILE__) + '/pkg'
    FileUtils.mkdir_p pkg_dir

    system 'gem build paste.gemspec && mv paste*.gem pkg/'
  end
  
  desc "Push the gem to rubygems.org"
  task :push => :build do
    system "gem push pkg/paste-#{Paste::VERSION}.gem"
  end
end