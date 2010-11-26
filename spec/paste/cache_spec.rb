require 'spec_helper'

describe Paste::Glue, 'building cached concatenations' do

  before :each do
    Paste::Test.write 'foo', 'foo()'
    Paste::Test.write 'bar', 'bar()'
    Paste::Test.write 'foo/baz', 'baz()'
  end

  it "should rebuild within the same instance of the unifier" do
    subject.rebuild

    subject.should have_in_result('foo', 'foo()')
    subject.should have_in_result('bar', 'bar()')
    subject.should have_in_result('foo/baz', 'baz()')
  end

  it "should rebuild pre-existing results despite modification times" do
    subject.rebuild

    Paste::Test.write 'foo', 'foo2()', Time.now - 42
    Paste::Test.write 'bar', 'bar2()', Time.now - 42
    Paste::Test.write 'foo/baz', 'baz2()', Time.now - 42

    subject.rebuild

    subject.should have_in_result('foo', 'foo2()')
    subject.should have_in_result('bar', 'bar2()')
    subject.should have_in_result('foo/baz', 'baz2()')
  end

  it "doesn't explode when one of the files is removed after a rebuild" do
    subject.rebuild

    Paste::Test.delete_source 'foo'

    expect{ subject.rebuild }.to_not raise_error
  end

end
