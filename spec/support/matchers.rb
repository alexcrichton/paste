def failed_not_contains_message file, contents
  msg = "Expected #{file} to contain:\n\t#{contents.gsub("\n", "\n\t")}\nWhen"
  
  if File.file?(file)
    msg += " it contained:\n#{File.read(file)}".gsub("\n", "\n\t")
  else
    msg += ' it did not exist.'
  end
  
  msg
end

RSpec::Matchers.define :have_in_sprocket do |sprocket, contents|
  sprocket += '.js' unless sprocket.end_with?('.js')

  match do |glue|
    File.join(glue.destination, sprocket).should have_contents(contents)
  end
  
  failure_message do |glue|
    failed_not_contains_message File.join(glue.destination, sprocket), contents
  end
end

RSpec::Matchers.define :have_contents do |contents|
  match do |file|
    File.file?(file) && File.read(file).chomp.should == contents.chomp
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

RSpec::Matchers.define :contain do |substr|
  match do |str|
    !str.index(substr).nil?
  end
end