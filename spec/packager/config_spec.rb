require 'spec_helper'

describe 'Configuration of Sprockets::Packager' do
  it "should allow a load path relative to the root" do
    @watcher = Sprockets::Packager::Watcher.new :load_path => ['sources'],
                                                :expand_includes => true
    
    source_dir = Sprockets::Packager.options[:root] + '/sources'
    File.open(source_dir.to_s + '/foo.js', 'w') { |f| f << 'foo()' }
    
    @watcher.sprocketize 'foo'

    File.read(@watcher.destination.join('foo.js')).should == 'foo()'
  end
end