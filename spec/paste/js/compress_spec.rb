require 'spec_helper'

describe Paste::JS::Unify, 'compression' do
  before :each do
    Paste::Test.write 'foo', "function foo() {};\n foo()"
    Paste::Test.write 'bar', "function bar() {};\n bar()"
  end

  it "should not compress the files when pasting" do
    result = subject.paste('foo').first
    
    subject.should have_in_result(result, "function foo() {};\n foo()")
  end

  it "should compress the previously generated result" do
    result = subject.paste('foo', 'bar').first
    
    subject.rebuild! :compress => 'google'

    contents = File.read subject.destination(result)
    contents.should_not contain("\n")
    contents.should =~ /function/
  end

  it "should allow the compilation level to be specified" do
    result = subject.paste('foo', 'bar').first
    
    subject.rebuild! :compress => 'google', :level => 'ADVANCED_OPTIMIZATIONS'

    # Everything should be optimized out
    subject.should have_in_result(result, '')
  end

end