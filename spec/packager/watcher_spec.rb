require 'spec_helper'

describe Sprockets::Packager::Watcher do
  
  before :each do
    @source_dir  = Sprockets::Packager.options[:load_path][0]
    FileUtils.mkdir_p @source_dir + '/foo'
    File.open(@source_dir + '/foo.js', 'w'){ |f| f << 'foo()' }
    File.open(@source_dir + '/bar.js', 'w'){ |f| f << 'bar()' }
    File.open(@source_dir + '/foo/baz.js', 'w'){ |f| f << 'baz()' }
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

      actual_file = @watcher.destination.join sprocket
      File.read(actual_file).chomp.should == "foo()\nbar()\nbaz()"
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

      File.read(@watcher.destination.join('foo.js')).should == "foo()"
      File.read(@watcher.destination.join('bar.js')).should == "bar()"
      File.read(@watcher.destination.join('foo/baz.js')).should == "baz()"
    end
    
    it "should return the sprockets with dependencies satisfied" do
      File.open(@source_dir + '/foo.js', 'w') { |f| 
        # Sprockets are smart apparently, have to have at least one line in file
        f << "//= require <bar>\nfoo()" 
      }

      @watcher.sprocketize('foo', 'bar').should == ['bar.js', 'foo.js']
    end
  end
  
end
