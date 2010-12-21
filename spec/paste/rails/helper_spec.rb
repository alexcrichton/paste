require 'spec_helper'

describe Paste::Rails::Helper do

  let(:helper) {
    Object.new.tap{ |o| o.class_eval{ include Paste::Rails::Helper } }
  }

  before :each do
    Paste::Rails.glue = Paste::Glue.new
  end

  after :each do
    Paste.config.no_cache = false
  end

  describe "working with javascript" do
    it "should register the include_javascript method" do
      helper.include_javascript 'foobar'

      helper.included_javascripts.should == ['foobar']
    end

    it "should allow multiple sources to be included at once" do
      helper.include_javascripts 'foo', 'bar'

      helper.included_javascripts.should == ['foo', 'bar']
    end

    it "shouldn't allow multiple sources to be in the list" do
      helper.include_javascripts 'foo', 'bar'
      helper.include_javascript 'foo'

      helper.included_javascripts.should == ['foo', 'bar']
    end

    it "should paste the sources when asked for" do
      helper.stub(:javascript_include_tag)
      glue = mock(Paste::Glue)
      Paste::Rails.glue = glue

      glue.should_receive(:paste).with('foo', 'bar').and_return(
        :javascripts => [],
        :stylesheets => []
      )

      helper.include_javascript 'foo'
      helper.javascript_tags 'bar'
    end

    it "should return the javascript include tags" do
      helper.should_receive(:javascript_include_tag).with(
          'foo', 'bar', instance_of(Hash)).and_return 'foo.js'
      Paste::Rails.stub(:glue).and_return(
        mock(Paste::Glue, :paste => {
          :javascripts => ['foo', 'bar'],
          :stylesheets => ['bar/baz']
        })
      )

      helper.javascript_tags('foo').should == 'foo.js'
    end

    it "doesn't cache javascripts when asked to not do so" do
      Paste::Test.write 'bar', 'test'
      Paste.config.no_cache = true
      helper.should_receive(:javascript_include_tag).with('bar.js')

      helper.javascript_tags('bar')
    end
  end

  describe "working with css" do
    it "registers the stylesheet method" do
      helper.stylesheet 'foobar'

      helper.included_stylesheets.should == {{} => ['foobar']}
    end

    it "allows link attributes to be specified as well" do
      helper.stylesheet 'foobar', :media => 'all'

      helper.included_stylesheets.should == {{:media => 'all'} => ['foobar']}
    end

    it "allows multiple sources to be included at once" do
      helper.include_stylesheets 'foo', 'bar'

      helper.included_stylesheets.should == {{} => ['foo', 'bar']}
    end

    it "allows multiple sources to be included at once with link attributes" do
      helper.include_stylesheets 'foo', 'bar', :media => 'print'

      helper.included_stylesheets.should == {{:media => 'print'} =>
        ['foo', 'bar']}
    end

    it "doesn't allow dupicate sources to be in the list" do
      helper.include_stylesheets 'foo', 'bar'
      helper.include_stylesheet 'foo'

      helper.included_stylesheets.should == {{} => ['foo', 'bar']}
    end

    it "doesn't allow duplicate sources with the same attributes" do
      helper.include_stylesheets 'foo', 'bar', :media => 'print'
      helper.include_stylesheet 'foo', :media => 'print'

      helper.included_stylesheets.should == {{:media => 'print'} =>
        ['foo', 'bar']}
    end

    it "doesn't modify the arrays of included stylesheets" do
      helper.include_stylesheet 'foo'
      helper.stub(:stylesheet_link_tag).and_return ''
      helper.stylesheet_tags

      helper.included_stylesheets.should == {{} => ['foo']}
    end

    it "should return the stylesheet link tags for what was included" do
      helper.include_stylesheets 'foo', 'bar'
      helper.should_receive(:stylesheet_link_tag).with(
          'foo', 'bar', instance_of(Hash)).and_return 'foo.css'

      helper.stylesheet_tags.should == 'foo.css'
    end

    it "should return the stylesheet link tags for what is specified" do
      helper.should_receive(:stylesheet_link_tag).with(
          'foo', 'bar', instance_of(Hash)).and_return 'foo.css'

      helper.stylesheet_tags('foo', 'bar').should == 'foo.css'
    end

    it "should include css required by the javascript" do
      Paste::Test.write 'foo.js', '//= require_css <bar>'
      helper.include_javascript 'foo'
      helper.should_receive(:stylesheet_link_tag).with(
          'bar', instance_of(Hash)).and_return 'bar.css'

      helper.stylesheet_tags.should == 'bar.css'
    end

    context "no caching" do
      before{ Paste.config.no_cache = true }

      it "doesn't give a cache argument" do
        helper.should_receive(:stylesheet_link_tag).with('bar', {})

        helper.stylesheet_tags('bar')
      end

      it "passes along stylesheet options" do
        helper.should_receive(:stylesheet_link_tag).with('bar', :foo => 'bar')

        helper.stylesheet_tags('bar', :foo => 'bar')
      end

      it "passes along stylesheet options included via #stylesheet" do
        helper.should_receive(:stylesheet_link_tag).with('bar', :foo => 'bar')

        helper.stylesheet 'bar', :foo => 'bar'

        helper.stylesheet_tags
      end

      it "keeps separate different option hashes" do
        helper.should_receive(:stylesheet_link_tag).with('bar', :bar => 'bar')
        helper.should_receive(:stylesheet_link_tag).with('foo', :foo => 'foo')

        helper.stylesheet 'foo', :foo => 'foo'
        helper.stylesheet 'bar', :bar => 'bar'

        helper.stylesheet_tags
      end

      it "by default doesn't add in any options" do
        helper.should_receive(:stylesheet_link_tag).with('bar', {})

        helper.stylesheet 'bar'

        helper.stylesheet_tags
      end
    end
  end

  describe "the default glue value" do
    it "should be a unifier by default" do
      Paste::Rails.glue.should be_a(Paste::Glue)
    end

    it "should be swappable" do
      Paste::Rails.glue = (other = Paste::Glue.new)

      Paste::Rails.glue.should == other
    end
  end
end
