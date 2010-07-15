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
    
    describe "regenerating files" do
      before :each do
        @watcher.watch_changes = true
      end

      it "should occur if any file is changed" do
        sprocket = @watcher.sprocketize('foo', 'bar')[0]

        File.open(@source_dir + '/foo.js', 'w') { |f| f << 'foobar()' }
        File.utime(Time.now, Time.now + 42, @source_dir + '/foo.js')

        @watcher.sprocketize('foo', 'bar')

        gen = @watcher.destination.join(sprocket)
        File.read(gen).chomp.should == "foobar()\nbar()"
      end

      it "should not occur if no files have changed" do
        sprocket = @watcher.sprocketize('foo', 'bar')[0]

        File.open(@source_dir + '/foo.js', 'w') { |f| f << 'foobar()' }
        File.utime(Time.now, Time.now - 42, @source_dir + '/foo.js')

        @watcher.sprocketize('foo', 'bar')

        gen = @watcher.destination.join(sprocket)
        File.read(gen).chomp.should == "foo()\nbar()"
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
    
    describe "regenerating files" do
      it "should only regenerate modified files" do
        @watcher.sprocketize('foo', 'bar', 'foo/baz')
        
        File.open(@source_dir + '/foo.js', 'w') { |f| f << 'foo(foo)' }
        File.utime(Time.now, Time.now - 42, @source_dir + '/foo.js')
        File.open(@source_dir + '/bar.js', 'w') { |f| f << 'bar(bar)' }
        File.utime(Time.now, Time.now + 42, @source_dir + '/bar.js')
        
        @watcher.sprocketize('foo', 'bar', 'foo/baz')
        
        File.read(@watcher.destination.join('foo.js')).should == "foo()"
        File.read(@watcher.destination.join('bar.js')).should == "bar(bar)"
        File.read(@watcher.destination.join('foo/baz.js')).should == "baz()"
      end
    end
  end
  
  it "should sprocketize a variety of regular/erb files" do
    @watcher = Sprockets::Packager::Watcher.new :expand_includes => false
    
    File.open(@source_dir + '/foobar.js.erb', 'w') { |f| f << '<%= 5 * 5 %>' }
    
    @watcher.render_erb
    sprocket = @watcher.sprocketize('foobar', 'foo')[0]
    File.read(@watcher.destination.join(sprocket)).chomp.should == "25\nfoo()"
  end
end
