require 'spec_helper'

describe Paste::Glue, 'compression' do
  before :each do
    Paste::Test.write 'foo', "function foo() {};\n foo()"
    Paste::Test.write 'bar', "function bar() {};\n bar()"
  end

  it "should not compress the files when pasting" do
    subject.paste('foo')

    subject.should have_in_result('foo', "function foo() {};\n foo()")
  end

  it "should allow the compilation level to be specified" do
    results = subject.paste('foo', 'bar')[:javascripts]

    subject.rebuild! :compress => 'google',
                     :compilation_level => 'ADVANCED_OPTIMIZATIONS'

    # Everything should be optimized out
    results.each do |result|
      subject.should have_in_result(result, '')
    end
  end

  shared_examples_for 'a regular compressor' do
    it "should compress the previously generated result" do
      results = subject.paste('foo', 'bar')[:javascripts]

      subject.rebuild! :compress => 'google'

      results.each do |result|
        contents = File.read subject.destination(result)
        contents.should_not contain("\n")
        contents.should =~ /function/
      end
    end
  end

  it_should_behave_like 'a regular compressor'

  describe "without java" do
    before :each do
      subject.stub(:has_java?).and_return false
    end

    it_should_behave_like 'a regular compressor'
  end
end
