source :rubygems

gemspec

group :development do
  gem 'rcov', :platform => :ruby_18
  gem 'simplecov', :platform => :ruby_19

  if RbConfig::CONFIG['host_os'] =~ /darwin/
    gem 'growl'
    gem 'rb-fsevent'
  end
end
