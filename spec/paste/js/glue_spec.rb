require 'spec_helper'

describe Paste do

  before :each do
    Paste::Test.write 'foo', 'foo()'
    Paste::Test.write 'bar', 'bar()'
    Paste::Test.write 'foo/baz', 'baz()'
  end

  describe Paste::JS::Unify do    
    it "should generate only one sprocket" do
      sprockets = subject.paste 'foo', 'bar', 'foo/baz'

      sprockets.size.should == 1
    end
    
    it "should generate the same sprocket for different forms of the input" do
      sprockets = subject.paste 'foo', 'bar', 'foo/baz'

      sprockets.should == subject.paste('foo', 'foo/baz.js', 'bar.js')
      sprockets.should == subject.paste('bar', 'foo.js', 'foo/baz')
    end
    
    it "should generate the concatenation when the destination doesn't exist" do
      sprocket = subject.paste('foo', 'bar', 'foo/baz')[0]

      subject.should have_in_sprocket(sprocket, "foo()\nbar()\nbaz()")
    end
    
    it "should rebuild the sprockets after the file has been removed" do
      sprocket = subject.paste('foo', 'bar', 'foo/baz')[0]

      Paste::Test.delete sprocket
      subject.paste('foo', 'bar', 'foo/baz')

      subject.should have_in_sprocket(sprocket, "foo()\nbar()\nbaz()")
    end
    
    it "should raise a descriptive exception when the sprocket doesn't exist" do
      lambda { 
        subject.paste 'random' 
      }.should raise_error(/source random/i)
    end
    
    describe "regenerating files" do
      it "should occur if any file is changed" do
        sprocket = subject.paste('foo', 'bar')[0]

        Paste::Test.write 'foo', 'foobar()', Time.now + 42
        subject.paste('foo', 'bar')

        subject.should have_in_sprocket(sprocket, "foobar()\nbar()")
      end
    
      it "should not occur if no files have changed" do
        sprocket = subject.paste('foo', 'bar')[0]

        Paste::Test.write 'foo', 'foobar', Time.now - 42
        subject.paste('foo', 'bar')

        subject.should have_in_sprocket(sprocket, "foo()\nbar()")
      end
      
      it "should update the registered sprockets only if they have changed" do
        subject = described_class.new

        result1 = subject.paste('foo').first
        result2 = subject.paste('bar', 'foo/baz').first
        Paste::Test.write 'foo', 'foobar()', Time.now - 42
        Paste::Test.write 'bar', 'barbar()', Time.now + 42

        subject.update_registered

        subject.should have_in_sprocket(result1, 'foo()')
        subject.should have_in_sprocket(result2, "barbar()\nbaz()")
      end
    end
  end
  
  describe Paste::JS::Chain do
    it "should return the sprockets given" do
      sprockets = subject.paste 'foo', 'bar', 'foo/baz'
  
      sprockets.should == ['foo.js', 'bar.js', 'foo/baz.js']
    end
    
    it "should generate the concatenation when the destination doesn't exist" do
      subject.paste('foo', 'bar', 'foo/baz')
  
      subject.should have_in_sprocket('foo', 'foo()')
      subject.should have_in_sprocket('bar', 'bar()')
      subject.should have_in_sprocket('foo/baz', 'baz()')
    end
    
    it "should return the sprockets with dependencies satisfied" do
      # Sprockets are smart apparently, have to have at least one line in file
      Paste::Test.write 'foo', <<-EOF
//= require <foo/bar>
//= require <bar>
ignored_line()
EOF
      Paste::Test.write 'bar', <<-EOF
//= require <foo/bar>
ignored_line()
EOF
      Paste::Test.write 'foo/bar', 'ignored_line()'
  
      subject.paste('foo', 'bar', 'foo/bar').should == ['foo/bar.js', 'bar.js', 'foo.js']
    end
    
    it "should raise an exception on circular dependencies" do
      # Sprockets are smart apparently, have to have at least one line in file
      Paste::Test.write 'foo', <<-EOF
//= require <bar>
ignored_line()
EOF
      Paste::Test.write 'bar', <<-EOF
//= require <foo>
ignored_line()
EOF

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
  
        subject.should have_in_sprocket('foo', 'foo()')
        subject.should have_in_sprocket('bar', 'bar(bar)')
        subject.should have_in_sprocket('foo/baz', 'baz()')
      end
      
      it "should update the registered sprockets only if they have changed" do
        subject = described_class.new

        subject.paste('foo')
        subject.paste('bar')
        Paste::Test.write 'foo', 'foobar()', Time.now - 42
        Paste::Test.write 'bar', 'barbar()', Time.now + 42

        subject.update_registered

        subject.should have_in_sprocket('foo', 'foo()')
        subject.should have_in_sprocket('bar', 'barbar()')
      end
    end
  end
end
