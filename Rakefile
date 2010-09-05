require 'rubygems'
require 'bundler/setup'

require 'rspec/core/rake_task'
Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new(:spec)

if RUBY_VERSION < '1.9'
  desc "Run all examples using rcov"
  RSpec::Core::RakeTask.new :rcov => :cleanup_rcov_files do |t|
    t.rcov = true
    t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,spec/support,spec/paste,spec/spec_helper.rb,db/*,/Library/Ruby/*,config/*"]
    t.rcov_opts << %[--no-html --aggregate coverage.data]
  end
end

task :cleanup_rcov_files do
  rm_rf 'coverage.data'
end

task :clobber do
  rm_rf 'pkg'
  rm_rf 'tmp'
  rm_rf 'coverage'
end
