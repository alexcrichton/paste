require 'spec_helper'

describe 'Compressing javascript files' do
  before :each do
    write_sprocket 'foo', "function foo() {};\n foo()"
    write_sprocket 'bar', "function bar() {};\n bar()"
    @watcher = Sprockets::Packager::Watcher.new
  end
  
  it "should not compress the files when sprocketizing" do
    sprocket = @watcher.sprocketize('foo').first
    
    @watcher.should have_in_sprocket(sprocket, "function foo() {};\n foo()")
  end

  it "should compress each individual file when rebuilding" do
    sprockets = @watcher.sprocketize('foo', 'bar')
    sprockets.each { |s| delete_generated s }
    
    @watcher.rebuild_cached_sprockets! :compress => 'google'
    sprockets.each do |sprocket|
      @watcher.destination.join(sprocket).read.should_not contain("\n")
    end
  end
  
end