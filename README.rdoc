Sprockets for Rails 3
=================

This gem lets you make use of [Sprockets](http://github.com/sstephenson/sprockets).

## Installing

In your Gemfile: `gem 'sprockets-packager'`

Then, `bundle install`

## Usage
Read up on how [Sprockets](http://github.com/sstephenson/sprockets) works to start taking advantage of it.

Put all of your javascript files in `app/javascripts`. You can even make erb javascript files to interpolate constants and such.

Now in your views, whenever you need javascript, just call

		<% include_sprocket 'foobar' %>

or
		
		<% include_sprockets 'foo/bar', 'foo', 'baz' %>
		
And then in your layout file,

		<%= sprockets_include_tag %>

And that's it! As long as you've got your dependencies in your JS managed all right, the sprockets themselves will be automatically generated for you

I would recommend you add `public/javascripts/*` to your gitignore. I find it silly to check in generated files anyway.

### Environments (default behavior)
#### Production
In production, whenever `sprockets_include_tag` is called, the unique filename is generated, and if the file does not exist, it is generated via `Sprockets::Secretary`.  
Subsequent calls to `sprockets_include_tag` will never update the generated sprocket, and there is no other way that the sprocket will be generated.

For deployment, you probably don't want the first request to every page spend time rebuild the sprocket for that page. This gem caches all of the built sprockets to the file `tmp/sprockets-cache/sprockets.yml`. You probably want to symlink the entire directory to your deployment, but you can also just symlink this file.

You then need to run the `rake sprockets:rebuild` before your deployment goes live to rebuild everything

#### Development
Here, whenever `sprockets_include_tag` is called, the files are examined and the dependency tree is determined. The files are then included in the order which satisfies the dependency tree.  
Every request will trigger a refresh of the generated files in addition to them being generated when `sprockets_include_tag` is called.

## Example

Assume that `app/javascripts/jquery.js` exists and we have these files:

### app/javascripts/foo.js

		//= require <jquery>
		//= require <foo/bar>
		
		$(function() {
			$('#foo').fadeIn().html($['BAR_VALUE']);
		});

### app/javascripts/foo/bar.js.erb

		//= require <jquery>

		$['BAR_VALUE'] = <%= Bar::BAR_VALUE %>;

### app/views/foo/index.html.erb
		
		<% include_sprocket 'foo' %>
		
		<div id='bar'>
			And the bar value for today is: <div id='foo'></div>
		</div>

And as long as your template has `<%= sprockets_include_tag %>`, the right javascript concatenation will be generated for you.	

See configuration below for details, but if `:expand_includes` is true, then `sprockets_include_tag` is equivalent to `javascript_include_tag 'jquery', 'foo/bar', 'foo'`.  
Otherwise, if `:expand_includes` is false, the three files will be concatenated into a file with a unique name, and it will be the only one served on the page

## Configuration

You can configure the packager through `Sprockets::Packager.options`. The following are recognized options:

* `:load_path` - an array of relative/absolute paths of where to load the sprockets from. Sprockets are interpreted as relative from any one of these paths. Default: `['app/javascripts']`
* `:destination` - This is the destination of generated sprockets to go. Default: `'public/javascripts'`
* `:root` - This is the root option passed to Sprockets::Secretary. Default: `Rails.root`
* `:tmp_path` - This is the absolute/relative place to place any generated files like ERB templates. Default `'tmp/sprockets-cache'`
* `:watch_changes` - Values as to whether to watch the file system for changes. If `true`, this will regenerate all necessary sprockets on each request. Default: `Rails.env.development?`
* `:expand_includes` - Value as to whether to expand javascript includes or to compact them into one asset. Default: `Rails.env.development?`
* `:serve_assets` - Value as to whether a Rack component should be installed to serve all static assets. This is useful for deployments on Heroku where the `public/` directory is not writeable. If this is used, the `:destination` is changed to `tmp/javascripts` and assets are served from there. Default: `false`

All configuration should be done in `config/application.rb` or `config/environments/*.rb`.

## License

Copyright &copy; 2009 Alex Crichton.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.