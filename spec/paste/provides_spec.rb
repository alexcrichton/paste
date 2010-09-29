require 'spec_helper'

describe Paste::Glue, 'as a css provider' do
  before :each do
    Paste::Test.write 'foo', '//= require_css <foo>'
  end

  it "should require the css" do
    result = subject.paste 'foo'
    result[:stylesheets].should == ['foo']
  end

  it "should not require multiple css twice" do
    Paste::Test.write 'bar', '//= require_css <foo>'

    subject.paste('foo', 'bar')[:stylesheets].should == ['foo']
  end
end
