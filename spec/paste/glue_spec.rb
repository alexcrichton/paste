require 'spec_helper'

describe Paste::Glue do
  before :each do
    Paste::Test.write 'foo', 'foo()'
    Paste::Test.write 'bar', 'bar()'
    Paste::Test.write 'foo/baz', 'baz()'
  end

  it "should return the sources given" do
    results = subject.paste('foo', 'bar', 'foo/baz')[:javascripts]

    results.sort.should == ['bar.js', 'foo.js', 'foo/baz.js']
  end

  it "should generate the concatenation when the destination doesn't exist" do
    subject.paste('foo', 'bar', 'foo/baz')

    subject.should have_in_result('foo', 'foo()')
    subject.should have_in_result('bar', 'bar()')
    subject.should have_in_result('foo/baz', 'baz()')
  end

  it "should return the sources with dependencies satisfied" do
    Paste::Test.write 'foo', "//= require <foo/bar>\n//= require <bar>"
    Paste::Test.write 'bar', '//= require <foo/bar>'
    Paste::Test.write 'foo/bar', 'foobar()'

    subject.paste('foo', 'bar', 'foo/bar')[:javascripts].should == ['foo/bar.js', 'bar.js', 'foo.js']
  end

  it "should raise an exception on circular dependencies" do
    Paste::Test.write 'foo', '//= require <bar>'
    Paste::Test.write 'bar', '//= require <foo>'

    lambda {
      subject.paste('foo', 'bar')
    }.should raise_exception(/circular dependency/i)
  end

  describe "regenerating files" do
    it "should only regenerate modified files" do
      subject.paste('foo', 'bar', 'foo/baz')

      Paste::Test.write 'foo', 'foo(foo)', Time.now - 42
      Paste::Test.write 'bar', 'bar(bar)', Time.now + 42

      subject.paste('foo', 'bar', 'foo/baz')

      subject.should have_in_result('foo', 'foo()')
      subject.should have_in_result('bar', 'bar(bar)')
      subject.should have_in_result('foo/baz', 'baz()')
    end

    it "should update the results only if the sources have changed" do
      subject = described_class.new

      subject.paste('foo')
      subject.paste('bar')
      Paste::Test.write 'foo', 'foobar()', Time.now - 42
      Paste::Test.write 'bar', 'barbar()', Time.now + 42

      subject.rebuild

      subject.should have_in_result('foo', 'foo()')
      subject.should have_in_result('bar', 'barbar()')
    end

    it "should watch for changes in dependencies as well" do
      Paste::Test.write 'foo', '//= require <bar>'
      Paste::Test.write 'bar', ''
      Paste::Test.write 'baz', ''
      subject.paste('foo')

      Paste::Test.write 'bar', '//= require <baz>', Time.now + 42

      subject.paste('foo')[:javascripts].should == ['baz.js', 'bar.js', 'foo.js']
    end

    it "should watch for changes in dependencies as well" do
      Paste::Test.write 'foo', '//= require <bar>'
      Paste::Test.write 'bar', ''
      Paste::Test.write 'baz', ''
      subject.paste('foo')

      Paste::Test.write 'bar', '//= require <baz>', Time.now + 42

      subject.paste('foo')[:javascripts].should == ['baz.js', 'bar.js', 'foo.js']
    end

    it "should watch for changes in very deep dependencies" do
      Paste::Test.write 'foo', ''
      Paste::Test.write 'bar', ''
      subject.paste('foo')

      Paste::Test.write 'foo', '//= require <bar>', Time.now + 42

      subject.paste('foo')[:javascripts].should == ['bar.js', 'foo.js']
    end

    it "should update dependencies when they've been rewritten using rebuild" do
      Paste::Test.write 'foo', ''
      Paste::Test.write 'baz', 'foobar'

      subject.paste('foo')
      Paste::Test.write 'foo', '//= require <baz>', Time.now + 42
      subject.rebuild
      Paste::Test.touch 'foo', Time.now - 1

      @result = subject.paste('foo')[:javascripts].should == ['baz.js', 'foo.js']
    end
  end

  describe "implicit dependencies" do
    before :each do
      Paste::Test.write 'foo', ''
      Paste::Test.write 'bar', '//= require <foo>'
    end

    it "should be included when pasting" do
      subject.paste('bar')[:javascripts].should == ['foo.js', 'bar.js']
    end

    it "should be regenerated" do
      result = subject.paste('bar')[:javascripts].first

      Paste::Test.write 'foo', 'foobar()', Time.now + 42

      subject.paste('bar')
      subject.should have_in_result(result, 'foobar()')
    end
  end
end
