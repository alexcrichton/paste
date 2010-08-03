require 'spec_helper'

describe Sprockets::Packager::Watcher do
  before :each do
    @watcher = Sprockets::Packager::Watcher.new
  end
  
  it "should render an erb file into a temporary location" do
    write_sprocket 'foo.js.erb', ''
    @watcher.render_erb

    @watcher.erb_path.join('foo.js').should exist
  end
  
  it "should execute the ERB in the file" do
    write_sprocket 'foo.js.erb', '<%= "foo" %><%= "bar" %>'

    @watcher.render_erb

    @watcher.erb_path.join('foo.js').should have_contents('foobar')
  end
  
  it "should handle deeply nested erb files alright" do
    write_sprocket 'foo/bar/baz.js.erb', '<%= "foo" %><%= "bar" %>'

    @watcher.render_erb

    @watcher.erb_path.join('foo/bar/baz.js').should have_contents('foobar')
  end
  
  it "shouldn't try to render regular js files" do
    write_sprocket 'foo', 'foo()'
    
    @watcher.render_erb

    @watcher.erb_path.join('foo.js').should_not exist
  end
  
  describe "modifying existing files" do
    before :each do
      @generated = @watcher.erb_path.join('foo.js')
      write_sprocket @generated, 'foo'
    end
    
    it "should regenerate the file if the source was modified" do
      # File is modified after the original one
      write_sprocket 'foo.js.erb', 'foobar', Time.now + 42

      @watcher.render_erb
      
      @generated.should have_contents('foobar')
    end
    
    it "should not regenerate the file if the source was not modified" do
      # File is modified before the original one
      write_sprocket 'foo.js.erb', 'foobar', Time.now - 42

      @watcher.render_erb
      
      @generated.should have_contents('foo')
    end
  end
end