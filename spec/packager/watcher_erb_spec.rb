require 'spec_helper'

describe Sprockets::Packager::Watcher do
  before :each do
    @watcher     = Sprockets::Packager::Watcher.new
    @source_file = Sprockets::Packager.options[:load_path][0] + '/foo.js.erb'
  end
  
  it "should render an erb file into a temporary location" do
    File.open(@source_file, 'w'){ |f| f << '' }

    @watcher.render_erb
    rendered = @watcher.erb_path.join 'foo.js'
    File.exists?(rendered).should be_true
  end
  
  it "should execute the ERB in the file" do
    File.open(@source_file, 'w'){ |f| f << '<%= "foo" %><%= "bar" %>' }

    @watcher.render_erb

    rendered = @watcher.erb_path.join 'foo.js'
    File.read(rendered).should == 'foobar'
  end
  
  it "should handle deeply nested erb files alright" do
    @source_file = File.dirname(@source_file) + '/foo/bar/baz.js.erb'
    FileUtils.mkdir_p File.dirname(@source_file)
    File.open(@source_file, 'w'){ |f| f << '<%= "foo" %><%= "bar" %>' }

    @watcher.render_erb

    File.exists?(@watcher.erb_path.join 'foo/bar/baz.js').should be_true
  end
  
  it "shouldn't try to render regular js files" do
    @source_file = @source_file.sub /\.erb$/, ''
    
    @watcher.render_erb

    rendered = @watcher.erb_path.join 'foo.js'
    File.exists?(rendered).should be_false
  end
  
  describe "modifying existing files" do
    before :each do
      @generated = @watcher.erb_path.join('foo.js')
      FileUtils.mkdir_p File.dirname(@generated)
      File.open(@generated, 'w') { |f| f << 'foo' }
    end
    
    it "should regenerate the file if the source was modified" do
      File.open(@source_file, 'w') { |f| f << 'foobar' }
      # Make this file be modified after the generated file
      File.utime(Time.now, Time.now + 42, @source_file)

      @watcher.render_erb
      File.read(@generated).should == 'foobar'
    end
    
    it "should not regenerate the file if the source was not modified" do
      File.open(@source_file, 'w') { |f| f << 'foobar' }
      # Make this file be modified before the generated file
      File.utime(Time.now, Time.now - 42, @source_file)

      @watcher.render_erb

      File.read(@generated).should == 'foo'
    end
  end
end