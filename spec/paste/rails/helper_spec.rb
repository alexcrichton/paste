require 'spec_helper'

describe Paste::Rails::Helper do
  
  before :each do
    @helper = Object.new
    @helper.class.send :include, subject
  end
  
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
    @helper.stub(:javascript_include_tag)
    @glue = mock(Paste::Glue)
    Paste::Rails.stub(:glue).and_return(@glue)

    @glue.should_receive(:paste).with('foo', 'bar')
    
    @helper.include_javascript 'foo'
    @helper.paste_tags 'bar'
  end

  it "should return the javascript include tags" do
    @helper.should_receive(:javascript_include_tag).with(
        'foo', 'bar').and_return 'foo.js'
    Paste::Rails.stub(:glue).and_return(
      mock(Paste::Glue, :paste => ['foo', 'bar'])
    )

    @helper.paste_tags('foo').should == 'foo.js'
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
