require 'spec_helper'

describe Paste::Glue, 'configuration' do
  it "should resolve absolute paths correctly" do
    absolute = File.expand_path(__FILE__)
    subject.resolve(absolute).should == absolute
  end

  it "should resolve a non-absolute path relative to the specified root" do
    subject.config.root = '/foo/bar'
    subject.resolve('nonexistent').should == '/foo/bar/nonexistent'
  end

  it "should allow relative paths to the root to be set for configuration" do
    subject.config.root           = '/foo/bar'
    subject.config.tmp_path       = 'tmp'
    subject.config.erb_path       = 'erb'
    subject.config.js_destination = 'dst'

    subject.tmp_path.should == '/foo/bar/tmp'
    subject.erb_path.should == '/foo/bar/erb'
    subject.destination.should == '/foo/bar/dst'
  end

  it "should allow absolute paths to the root to be set for configuration" do
    subject.config.root           = '/foo/bar'
    subject.config.tmp_path       = '/tmp'
    subject.config.erb_path       = '/erb'
    subject.config.js_destination = '/dst'

    subject.tmp_path.should == '/tmp'
    subject.erb_path.should == '/erb'
    subject.destination.should == '/dst'
  end
end
