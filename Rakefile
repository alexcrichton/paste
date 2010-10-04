require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

if RUBY_VERSION < '1.9'
  desc "Run all examples using rcov"
  RSpec::Core::RakeTask.new :rcov => :cleanup_rcov_files do |t|
    t.rcov = true
    t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,spec/support,spec/paste,spec/spec_helper.rb"]
  end
end

task :cleanup_rcov_files do
  rm_rf 'coverage*'
end

task :clobber => :cleanup_rcov_files do
  rm_rf 'pkg'
  rm_rf 'tmp'
end
