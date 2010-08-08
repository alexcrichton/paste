require 'spec_helper'

describe Paste::JS::Unify, 'compression' do
  before :each do
    Paste::JS::Test.write 'foo', "function foo() {};\n foo()"
    Paste::JS::Test.write 'bar', "function bar() {};\n bar()"
  end

  it "should not compress the files when pasting" do
    result = subject.paste('foo')[:javascript].first
    
    subject.should have_in_result(result, "function foo() {};\n foo()")
  end

  it "should compress the previously generated result" do
    result = subject.paste('foo', 'bar')[:javascript].first
    
    begin
      subject.rebuild! :compress => 'google'
    rescue SocketError
      pending 'Error connecting to google'
    end

    contents = File.read subject.destination(result)
    contents.should_not contain("\n")
    contents.should =~ /function/
  end

  it "should allow the compilation level to be specified" do
    result = subject.paste('foo', 'bar')[:javascript].first
    
    begin
      subject.rebuild! :compress => 'google', :level => 'ADVANCED_OPTIMIZATIONS'
    rescue SocketError
      pending 'Error connecting to google'
    end

    # Everything should be optimized out
    subject.should have_in_result(result, '')
  end

end