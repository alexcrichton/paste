require 'spec_helper'

describe Paste::Rails::Helper do
  
  before :each do
    @helper = Object.new
    @helper.class.send :include, subject
  end

  describe "working with javascript" do
    it "should register the include_javascript method" do
      @helper.include_javascript 'foobar'

      @helper.included_javascripts.should == ['foobar']
    end

    it "should allow multiple sources to be included at once" do
      @helper.include_javascripts 'foo', 'bar'

      @helper.included_javascripts.should == ['foo', 'bar']
    end

    it "shouldn't allow multiple sources to be in the list" do
      @helper.include_javascripts 'foo', 'bar'
      @helper.include_javascript 'foo'

      @helper.included_javascripts.should == ['foo', 'bar']
    end

    it "should paste the sources when asked for" do
      @helper.stub(:javascript_include_tag).and_return ''
      @glue = mock(Paste::Glue)
      Paste::Rails.stub(:glue).and_return(@glue)

      @glue.should_receive(:paste).with('foo', 'bar').and_return(
        :javascripts => [],
        :css         => []
      )

      @helper.include_javascript 'foo'
      @helper.paste_js_tags 'bar'
    end

    it "should return the javascript include tags" do
      @helper.should_receive(:javascript_include_tag).with(
          'foo', 'bar').and_return 'foo.js'
      Paste::Rails.stub(:glue).and_return(
        mock(Paste::Glue, :paste => {
          :javascript => ['foo', 'bar'],
          :css        => ['bar/baz']
        })
      )

      @helper.paste_js_tags('foo').should == 'foo.js'
    end
  end

  describe "working with css" do
    it "should register the include_css method" do
      @helper.include_css 'foobar'

      @helper.included_css.should == ['foobar']
    end

    it "should allow multiple sources to be included at once" do
      @helper.include_css 'foo', 'bar'

      @helper.included_css.should == ['foo', 'bar']
    end

    it "shouldn't allow multiple sources to be in the list" do
      @helper.include_css 'foo', 'bar'
      @helper.include_css 'foo'

      @helper.included_css.should == ['foo', 'bar']
    end

    it "should return the stylesheet link tags for what was included" do
      @helper.include_css 'foo', 'bar'
      @helper.should_receive(:stylesheet_link_tag).with(
          'foo', 'bar', instance_of(Hash)).and_return 'foo.css'
      Paste::Rails.stub(:glue).and_return(Paste::JS::Chain.new)

      @helper.paste_css_tags.should == 'foo.css'
    end
    
    it "should return the stylesheet link tags for what is specified" do
      @helper.should_receive(:stylesheet_link_tag).with(
          'foo', 'bar', instance_of(Hash)).and_return 'foo.css'
      Paste::Rails.stub(:glue).and_return(Paste::JS::Chain.new)

      @helper.paste_css_tags('foo', 'bar').should == 'foo.css'
    end
    
    it "should include css required by the javascript" do
      Paste::JS::Test.write 'foo.js', '//= require_css <bar>'
      @helper.include_javascript 'foo'
      @helper.should_receive(:stylesheet_link_tag).with(
          'bar', instance_of(Hash)).and_return 'bar.css'

      @helper.paste_css_tags.should == 'bar.css'
    end
  end

  describe "the default glue value" do
    it "should be a unifier by default" do
      Paste::Rails.glue.should be_a(Paste::JS::Unify)
    end

    it "should be swappable" do
      @chain            = Paste::JS::Chain
      Paste::Rails.glue = @chain

      Paste::Rails.glue.should == @chain
    end
  end  
end
