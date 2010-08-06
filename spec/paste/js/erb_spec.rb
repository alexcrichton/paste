require 'spec_helper'

describe Paste::JS::Base do

  it "should render an erb file into a temporary location" do
    Paste::Test.write 'foo.js.erb', ''
    subject.render_all_erb
  
    subject.erb_path('foo.js').should exist
  end
  
  it "should execute the ERB in the file" do
    Paste::Test.write 'foo.js.erb', '<%= "foo" %><%= "bar" %>'
    subject.render_all_erb
  
    subject.erb_path('foo.js').should have_contents('foobar')
  end

  it "should handle deeply nested erb files alright" do
    Paste::Test.write 'foo/bar/baz.js.erb', '<%= "foo" %><%= "bar" %>'
    subject.render_all_erb
  
    subject.erb_path('foo/bar/baz.js').should have_contents('foobar')
  end
  
  it "shouldn't try to render regular js files" do
    Paste::Test.write 'foo', 'foo()'
    subject.render_all_erb
  
    subject.erb_path('foo.js').should_not exist
  end
  
  context "pasting a variety of regular/erb files" do
    shared_examples_for 'an erb paster' do
      it "should use the generated ERB file when pasting" do
        Paste::Test.write 'foo.js.erb', '<%= "foo" %><%= "bar" %>'
        Paste::Test.write 'bar', 'bar()'
        subject.render_all_erb

        subject.paste('foo', 'bar')
      end
    end

    describe Paste::JS::Chain do
      it_should_behave_like 'an erb paster'
    end

    describe Paste::JS::Unify do
      it_should_behave_like 'an erb paster'
    end
  end

  describe "modifying existing files" do
    before :each do
      Paste::Test.write subject.erb_path('foo.js'), 'foo'
    end
    
    it "should regenerate the file if the source was modified" do
      # File is modified after the original one
      Paste::Test.write 'foo.js.erb', 'foobar', Time.now + 42
  
      subject.render_all_erb
      
      subject.erb_path('foo.js').should have_contents('foobar')
    end
    
    it "should not regenerate the file if the source was not modified" do
      # File is modified before the original one
      Paste::Test.write 'foo.js.erb', 'foobar', Time.now - 42
      subject.render_all_erb
      
      subject.erb_path('foo.js').should have_contents('foo')
    end
  end
end