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

  it "returns the sources with dependencies satisfied" do
    Paste::Test.write 'foo', "//= require <foo/bar>\n//= require <bar>"
    Paste::Test.write 'bar', '//= require <foo/bar>'
    Paste::Test.write 'foo/bar', 'foobar()'

    subject.paste('foo', 'bar', 'foo/bar')[:javascripts].should == ['foo/bar.js', 'bar.js', 'foo.js']
  end

  it "raises an exception on circular dependencies" do
    Paste::Test.write 'foo', '//= require <bar>'
    Paste::Test.write 'bar', '//= require <foo>'

    expect {
      subject.paste('foo', 'bar')
    }.to raise_error(Paste::CircularReferenceError, /circular dependency/i)
  end

  it "raises an exception on nonexistent dependencies" do
    expect {
      subject.paste('nonexistent')
    }.to raise_error(Paste::ResolveError, /nonexistent.*couldn't be found/i)
  end

  it "raises a descriptive exception when a dependency is removed" do
    Paste::Test.write 'nonexistent', ''
    subject.paste('nonexistent')
    Paste::Test.delete_source 'nonexistent'

    expect {
      subject.paste('nonexistent')
    }.to raise_error(Paste::ResolveError, /nonexistent.*couldn't be found/i)
  end

  describe "regenerating files" do
    it "watches for changes in dependencies" do
      Paste::Test.write 'foo', '//= require <bar>'
      Paste::Test.write 'bar', ''
      Paste::Test.write 'baz', ''
      subject.paste('foo')

      Paste::Test.write 'bar', '//= require <baz>', Time.now + 42

      subject.paste('foo')[:javascripts].should == ['baz.js', 'bar.js', 'foo.js']
    end

    it "watches for changes in deep dependencies" do
      Paste::Test.write 'foo', ''
      Paste::Test.write 'bar', ''
      subject.paste('foo')

      Paste::Test.write 'foo', '//= require <bar>', Time.now + 42

      subject.paste('foo')[:javascripts].should == ['bar.js', 'foo.js']
    end

  end
end
