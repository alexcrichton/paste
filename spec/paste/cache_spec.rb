require 'spec_helper'

describe Paste::Glue, 'building cached concatenations' do

  before :each do
    Paste::Test.write 'foo', 'foo()'
    Paste::Test.write 'bar', 'bar()'
    Paste::Test.write 'foo/baz', 'baz()'

    @result = subject.paste('foo', 'bar', 'foo/baz')[:javascripts].first
    Paste::Test.delete @result
  end

  it "should rebuild within the same instance of the unifier" do
    subject.rebuild!

    subject.should have_in_result(@result, "foo()\nbar()\nbaz()")
  end

  it "should allow another watcher to rebuild it" do
    subject = Paste::Unify.new
    subject.rebuild!

    subject.should have_in_result(@result, "foo()\nbar()\nbaz()")
  end

  it "should rebuild pre-existing results despite modification times" do
    # Make the file exist and have the last modified time of the sources
    # to be previous to now
    subject.paste('foo', 'bar', 'foo/baz')
    Paste::Test.write 'foo', 'foo2()', Time.now - 42
    Paste::Test.write 'bar', 'bar2()', Time.now - 42
    Paste::Test.write 'foo/baz', 'baz2()', Time.now - 42

    subject.rebuild!

    subject.should have_in_result(@result, "foo2()\nbar2()\nbaz2()")
  end

  it "should ignore cached results which no longer exist" do
    Paste::Test.delete_source 'foo'
    Paste::Test.delete_source 'bar'

    subject.rebuild!
    subject.destination(@result).should_not exist
  end
end
