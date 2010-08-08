require 'spec_helper'

shared_examples_for 'a css provider' do
  before :each do
    Paste::JS::Test.write 'foo', '//= require_css <foo>'
    Paste::CSS::Test.write 'foo', ''
  end
  
  it "should require the css" do
    result = subject.paste 'foo'
    result[:css].should == ['foo']
  end
  
  it "should not require multiple css twice" do
    Paste::JS::Test.write 'bar', '//= require_css <foo>'

    subject.paste('foo', 'bar')[:css].should == ['foo']
  end
end

describe 'Providing CSS from javascript' do
  describe Paste::JS::Unify do
    it_should_behave_like 'a css provider'
  end

  describe Paste::JS::Chain do
    it_should_behave_like 'a css provider'
  end
end