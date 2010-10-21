require 'bundler'
Bundler.setup
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

if RUBY_VERSION < '1.9'
  desc "Run all examples using rcov"
  RSpec::Core::RakeTask.new :coverage => :cleanup_coverage_files do |t|
    t.rcov = true
    t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,spec/support,spec/paste,spec/spec_helper.rb"]
  end
else
  desc 'Run all tests using cover_me'
  task :coverage => :cleanup_coverage_files do
    require 'cover_me'

    CoverMe.config do |c|
      c.project.root = File.expand_path('..', __FILE__)
    end

    require 'rspec/core'
    spec_dir = File.expand_path('../spec', __FILE__)
    RSpec::Core::Runner.disable_autorun!
    RSpec::Core::Runner.run [spec_dir], STDERR, STDOUT

    CoverMe.complete!
  end
end

task :cleanup_coverage_files do
  rm_rf 'coverage*'
end

task :clobber => :cleanup_rcov_files do
  rm_rf 'pkg'
  rm_rf 'tmp'
end
