require 'spec_helper'

describe Sprockets::Packager::Watcher do
  
  before :each do
    write_sprocket 'foo', 'foo()'
    write_sprocket 'bar', 'bar()'
    write_sprocket 'foo/baz', 'baz()'
  end

  context "compact mode" do    
    before :each do
      @watcher = Sprockets::Packager::Watcher.new :expand_includes => false
    end
    
    it "should generate only one sprocket" do
      sprockets = @watcher.sprocketize ['foo', 'bar', 'foo/baz']
      
      sprockets.size.should == 1
    end
    
    it "should generate the concatenation when the destination doesn't exist" do
      sprocket = @watcher.sprocketize('foo', 'bar', 'foo/baz')[0]

      @watcher.should have_in_sprocket(sprocket, "foo()\nbar()\nbaz()")
    end

    it "should rebuild the sprockets after the file has been removed" do
      sprocket = @watcher.sprocketize('foo', 'bar', 'foo/baz')[0]

      delete_generated sprocket
      @watcher.sprocketize('foo', 'bar', 'foo/baz')

      @watcher.should have_in_sprocket(sprocket, "foo()\nbar()\nbaz()")
    end

    it "should raise a descriptive exception when the sprocket doesn't exist" do
      lambda { 
        @watcher.sprocketize 'random' 
      }.should raise_exception(/sprocket random/i)
    end

    describe "regenerating files" do
      before :each do
        @watcher.watch_changes = true
      end

      it "should occur if any file is changed" do
        sprocket = @watcher.sprocketize('foo', 'bar')[0]

        write_sprocket 'foo', 'foobar()', Time.now + 42
        @watcher.sprocketize('foo', 'bar')

        @watcher.should have_in_sprocket(sprocket, "foobar()\nbar()")
      end

      it "should not occur if no files have changed" do
        sprocket = @watcher.sprocketize('foo', 'bar')[0]

        write_sprocket 'foo', 'foobar', Time.now - 42
        @watcher.sprocketize('foo', 'bar')

        @watcher.should have_in_sprocket(sprocket, "foo()\nbar()")
      end
    end
  end
  
  context "expanded mode" do
    before :each do
      @watcher = Sprockets::Packager::Watcher.new :expand_includes => true
    end

    it "should return the sprockets given" do
      sprockets = @watcher.sprocketize 'foo', 'bar', 'foo/baz'

      sprockets.should == ['foo.js', 'bar.js', 'foo/baz.js']
    end
    
    it "should generate the concatenation when the destination doesn't exist" do
      @watcher.sprocketize('foo', 'bar', 'foo/baz')[0]

      @watcher.should have_in_sprocket('foo', 'foo()')
      @watcher.should have_in_sprocket('bar', 'bar()')
      @watcher.should have_in_sprocket('foo/baz', 'baz()')
    end
    
    it "should return the sprockets with dependencies satisfied" do
      # Sprockets are smart apparently, have to have at least one line in file
      write_sprocket 'foo', "//= require <bar>\nfoo()" 

      @watcher.sprocketize('foo', 'bar').should == ['bar.js', 'foo.js']
    end
    
    describe "regenerating files" do
      it "should only regenerate modified files" do
        @watcher.sprocketize('foo', 'bar', 'foo/baz')

        write_sprocket 'foo', 'foo(foo)', Time.now - 42
        write_sprocket 'bar', 'bar(bar)', Time.now + 42

        @watcher.sprocketize('foo', 'bar', 'foo/baz')

        @watcher.should have_in_sprocket('foo', 'foo()')
        @watcher.should have_in_sprocket('bar', 'bar(bar)')
        @watcher.should have_in_sprocket('foo/baz', 'baz()')
      end
    end
  end
  
  it "should sprocketize a variety of regular/erb files" do
    @watcher = Sprockets::Packager::Watcher.new :expand_includes => false

    write_sprocket 'foobar.js.erb', '<%= 5 * 5 %>'
    @watcher.render_erb

    sprocket = @watcher.sprocketize('foobar', 'foo')[0]
    @watcher.should have_in_sprocket(sprocket, "25\nfoo()")
  end
end
