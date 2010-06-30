Sprockets for Rails 3
=================

This gem lets you make use of [Sprockets](http://github.com/sstephenson/sprockets).

## Installing:

In your Gemfile: `gem 'sprockets-packager', :git => 'git://github.com/alexcrichton/sprockets-packager.git'`


## Usage
Read up on how [Sprockets](http://github.com/sstephenson/sprockets) works to start taking advantage of it.

Put all of your javascript files in `app/javascripts`. You can even make erb javascript files to interpolate constants and such.

Now in your views, whenever you need javascript, just call

		<%= include_sprocket 'foobar' %>
or
		<%= include_sprockets 'foo/bar', 'foo', 'baz' %>
		
And then in your layout file,

		<%= sprockets_include_tag %>

And that's it! As long as you've got your dependencies in your JS managed all right, the sprockets themselves will be automatically generated for you

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

## License

Copyright &copy; 2009 Alex Crichton.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.