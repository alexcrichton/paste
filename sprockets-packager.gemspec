# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sprockets-packager}
  s.version = "1.0.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alex Crichton"]
  s.date = %q{2010-07-15}
  s.description = %q{Sprocket Packaging for Rails 3}
  s.email = %q{alex@alexcrichton.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.md"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README.md",
     "Rakefile",
     "VERSION",
     "lib/sprockets-packager.rb",
     "lib/sprockets/packager.rb",
     "lib/sprockets/packager/erb_helper.rb",
     "lib/sprockets/packager/helper.rb",
     "lib/sprockets/packager/rack_updater.rb",
     "lib/sprockets/packager/railtie.rb",
     "lib/sprockets/packager/version.rb",
     "lib/sprockets/packager/watcher.rb",
     "spec/packager/config_spec.rb",
     "spec/packager/helper_spec.rb",
     "spec/packager/watcher_erb_spec.rb",
     "spec/packager/watcher_spec.rb",
     "spec/spec_helper.rb",
     "sprockets-packager.gemspec"
  ]
  s.homepage = %q{http://github.com/alexcrichton/sprockets-packager}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{sprockets-packager-1.0.9}
  s.test_files = [
    "spec/packager/config_spec.rb",
     "spec/packager/helper_spec.rb",
     "spec/packager/watcher_erb_spec.rb",
     "spec/packager/watcher_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sprockets>, [">= 0"])
    else
      s.add_dependency(%q<sprockets>, [">= 0"])
    end
  else
    s.add_dependency(%q<sprockets>, [">= 0"])
  end
end

