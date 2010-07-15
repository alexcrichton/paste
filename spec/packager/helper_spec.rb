require 'spec_helper'

describe Sprockets::Packager::Helper do
  
  before :each do
    @helper = Object.new
    @helper.class.send :include, Sprockets::Packager::Helper
  end
  
  it "should register the include_sprocket method" do
    @helper.include_sprocket 'foobar'
    
    @helper.included_sprockets.should == ['foobar']
  end
  
  it "should allow multiple sprockets to be included at once" do
    @helper.include_sprockets 'foo', 'bar'
    
    @helper.included_sprockets.should == ['foo', 'bar']
  end
  
  it "shouldn't allow multiple sprockets to be in the list" do
    @helper.include_sprockets 'foo', 'bar'
    @helper.include_sprocket 'foo'
    
    @helper.included_sprockets.should == ['foo', 'bar']
  end
  
  it "should sprocketize the sprockets when asked for" do
    @helper.stub(:javascript_include_tag)
    @watcher = mock(Sprockets::Packager::Watcher)
    Sprockets::Packager.stub(:watcher).and_return(@watcher)

    @watcher.should_receive(:sprocketize).with('foo', 'bar')
    
    @helper.include_sprocket 'foo'
    @helper.sprockets_include_tag 'bar'
  end
end