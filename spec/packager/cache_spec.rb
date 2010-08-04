require 'spec_helper'

describe Sprockets::Packager::Watcher do
  
  before :each do
    write_sprocket 'foo', 'foo()'
    write_sprocket 'bar', 'bar()'
    write_sprocket 'foo/baz', 'baz()'
    @watcher = Sprockets::Packager::Watcher.new :expand_includes => false
  end

  context "rebuilding cached sprockets" do
    before :each do
      @sprocket = @watcher.sprocketize('foo', 'bar', 'foo/baz')[0]
      delete_generated @sprocket
    end

    it "should rebuild within the same watcher" do
      @watcher.rebuild_cached_sprockets!

      @watcher.should have_in_sprocket(@sprocket, "foo()\nbar()\nbaz()")
    end
    
    it "should allow another watcher to rebuild it" do
      @watcher = Sprockets::Packager::Watcher.new :expand_includes => false
      @watcher.rebuild_cached_sprockets!

      @watcher.should have_in_sprocket(@sprocket, "foo()\nbar()\nbaz()")
    end
  end
    
end
