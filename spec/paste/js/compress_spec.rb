require 'spec_helper'

describe Paste::JS::Unify, 'compression' do
  before :each do
    Paste::Test.write 'foo', "function foo() {};\n foo()"
    Paste::Test.write 'bar', "function bar() {};\n bar()"
  end

  it "should not compress the files when sprocketizing" do
    sprocket = subject.paste('foo').first
    
    subject.should have_in_sprocket(sprocket, "function foo() {};\n foo()")
  end

  it "should compress the previously generated sprocket" do
    sprocket = subject.paste('foo', 'bar').first
    
    subject.rebuild! :compress => 'google'

    contents = File.read subject.destination(sprocket)
    contents.should_not contain("\n")
    contents.should =~ /function/
  end

  it "should allow the compilation level to be specified" do
    sprocket = subject.paste('foo', 'bar').first
    
    subject.rebuild! :compress => 'google', :level => 'ADVANCED_OPTIMIZATIONS'

    # Everything should be optimized out
    subject.should have_in_sprocket(sprocket, '')
  end

end