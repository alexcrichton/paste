require 'spec_helper'

describe Paste do

  before :each do
    Paste::Test.write 'foo', 'foo()'
    Paste::Test.write 'bar', 'bar()'
    Paste::Test.write 'foo/baz', 'baz()'
  end

  describe Paste::JS::Unify do    
    it "should generate only one result" do
      results = subject.paste 'foo', 'bar', 'foo/baz'

      results.size.should == 1
    end
    
    it "should generate the same results for different forms of the input" do
      results = subject.paste 'foo', 'bar', 'foo/baz'

      results.should == subject.paste('foo', 'foo/baz.js', 'bar.js')
      results.should == subject.paste('bar', 'foo.js', 'foo/baz')
    end
    
    it "should generate the concatenation when the destination doesn't exist" do
      result = subject.paste('foo', 'bar', 'foo/baz').first

      subject.should have_in_result(result, "foo()\nbar()\nbaz()")
    end
    
    it "should rebuild the results after the file has been removed" do
      result = subject.paste('foo', 'bar', 'foo/baz').first

      Paste::Test.delete result
      subject.paste('foo', 'bar', 'foo/baz')

      subject.should have_in_result(result, "foo()\nbar()\nbaz()")
    end
    
    it "should raise a descriptive exception when the source doesn't exist" do
      lambda { 
        subject.paste 'random' 
      }.should raise_error(/source random/i)
    end

    describe "regenerating files" do
      it "should occur if any file is changed" do
        result = subject.paste('foo', 'bar').first

        Paste::Test.write 'foo', 'foobar()', Time.now + 42
        subject.paste('foo', 'bar')

        subject.should have_in_result(result, "foobar()\nbar()")
      end

      it "should not occur if no files have changed" do
        result = subject.paste('foo', 'bar').first

        Paste::Test.write 'foo', 'foobar', Time.now - 42
        subject.paste('foo', 'bar')

        subject.should have_in_result(result, "foo()\nbar()")
      end
      
      it "should update the results only if the source have changed" do
        subject = described_class.new

        result1 = subject.paste('foo').first
        result2 = subject.paste('bar', 'foo/baz').first
        Paste::Test.write 'foo', 'foobar()', Time.now - 42
        Paste::Test.write 'bar', 'barbar()', Time.now + 42

        subject.rebuild

        subject.should have_in_result(result1, 'foo()')
        subject.should have_in_result(result2, "barbar()\nbaz()")
      end
    end
  end
  
  describe Paste::JS::Chain do
    it "should return the sources given" do
      results = subject.paste 'foo', 'bar', 'foo/baz'

      results.should == ['foo.js', 'bar.js', 'foo/baz.js']
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
  
      subject.paste('foo', 'bar', 'foo/bar').should == ['foo/bar.js', 'bar.js', 'foo.js']
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
    end
    
    describe "implicit dependencies" do
      before :each do
        Paste::Test.write 'foo', ''
        Paste::Test.write 'bar', '//= require <foo>'
      end

      it "should be included when pasting" do
        subject.paste('bar').should == ['foo.js', 'bar.js']
      end

      it "should be regenerated" do
        result = subject.paste('bar').first
        
        Paste::Test.write 'foo', 'foobar()', Time.now + 42

        subject.paste('bar')
        subject.should have_in_result(result, 'foobar()')
      end
    end
  end
end
