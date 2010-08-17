# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{paste}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alex Crichton"]
  s.date = %q{2010-08-17}
  s.description = %q{Asset Management for Rails}
  s.email = ["alex@alexcrichton.com"]
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "README.rdoc",
     "VERSION",
     "lib/paste.rb",
     "lib/paste/capistrano.rb",
     "lib/paste/css/base.rb",
     "lib/paste/glue.rb",
     "lib/paste/js/base.rb",
     "lib/paste/js/cache.rb",
     "lib/paste/js/chain.rb",
     "lib/paste/js/compress.rb",
     "lib/paste/js/erb_renderer.rb",
     "lib/paste/js/unify.rb",
     "lib/paste/parser/sprockets.rb",
     "lib/paste/rails.rb",
     "lib/paste/rails/helper.rb",
     "lib/paste/rails/railtie.rb",
     "lib/paste/rails/updater.rb",
     "lib/paste/resolver.rb",
     "lib/paste/version.rb"
  ]
  s.homepage = %q{http://github.com/alexcrichton/paste}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{JS and CSS dependency management}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sprockets>, [">= 0"])
      s.add_runtime_dependency(%q<closure-compiler>, [">= 0"])
      s.add_runtime_dependency(%q<paste>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0.0.beta4"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 2.0.0.beta.19"])
    else
      s.add_dependency(%q<sprockets>, [">= 0"])
      s.add_dependency(%q<closure-compiler>, [">= 0"])
      s.add_dependency(%q<paste>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 3.0.0.beta4"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 2.0.0.beta.19"])
    end
  else
    s.add_dependency(%q<sprockets>, [">= 0"])
    s.add_dependency(%q<closure-compiler>, [">= 0"])
    s.add_dependency(%q<paste>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 3.0.0.beta4"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 2.0.0.beta.19"])
  end
end

