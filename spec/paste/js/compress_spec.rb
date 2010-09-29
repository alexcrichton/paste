require 'spec_helper'

describe Paste::JS::Unify, 'compression' do
  before :each do
    Paste::JS::Test.write 'foo', "function foo() {};\n foo()"
    Paste::JS::Test.write 'bar', "function bar() {};\n bar()"
  end

  it "should not compress the files when pasting" do
    result = subject.paste('foo')[:javascripts].first

    subject.should have_in_result(result, "function foo() {};\n foo()")
  end

  it "should compress the previously generated result" do
    result = subject.paste('foo', 'bar')[:javascripts].first

    subject.rebuild! :compress => 'google'

    contents = File.read subject.destination(result)
    contents.should_not contain("\n")
    contents.should =~ /function/
  end

  it "should allow the compilation level to be specified" do
    result = subject.paste('foo', 'bar')[:javascripts].first

    subject.rebuild! :compress => 'google',
                     :compilation_level => 'ADVANCED_OPTIMIZATIONS'

    # Everything should be optimized out
    subject.should have_in_result(result, '')
  end

  it "should compress even when java cannot be found (using the web api)" do
    result = subject.paste('foo', 'bar')[:javascripts].first
    subject.stub(:has_java?).and_return false

    subject.rebuild! :compress => 'google'

    contents = File.read subject.destination(result)
    contents.should_not contain("\n")
    contents.should =~ /function/
  end

end
