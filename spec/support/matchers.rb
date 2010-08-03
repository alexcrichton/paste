def failed_not_contains_message file, contents
  msg = "Expected #{file} to contain:\n\t#{contents.gsub("\n", "\n\t")}\nWhen"
  
  if File.exists?(file)
    msg += " it contained:\n#{File.read(file)}".gsub("\n", "\n\t")
  else
    msg += ' it did not exist.'
  end
  
  msg
end

RSpec::Matchers.define :have_in_sprocket do |sprocket, contents|
  sprocket += '.js' unless sprocket.end_with?('.js')

  match do |watcher|
    watcher.destination.join(sprocket).should have_contents(contents)
  end
  
  failure_message do |watcher|
    failed_not_contains_message watcher.destination.join(sprocket), contents
  end
end

RSpec::Matchers.define :have_contents do |contents|
  match do |file|
    File.read(file).chomp.should == contents.chomp
  end

  failure_message do |file|
    failed_not_contains_message file, contents
  end
end

RSpec::Matchers.define :exist do
  match do |file|
    File.exists?(file)
  end
end