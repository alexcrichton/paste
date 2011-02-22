# Paste

This gem simplifies dependencies between javascript and easily allows requiring of javascript.

## Installing

In your Gemfile: `gem 'paste'`

Then, `bundle install`

## Usage
Put all of your javascript files in `app/javascripts`. You can even make erb javascript files to interpolate constants and such.

Now in your views, whenever you need javascript or a stylesheet, just call

    <% javascript 'some/javascript/file' %>
    <% stylesheet 'some/css/file' %>

or

    <% javascript 'foo/bar', 'foo', 'baz' %>

And then in your layout file,

    <%= stylesheet_tags %>
    <%= javascript_tags %>

And that's it! I would recommend you add `public/javascripts/*` to the ignore list of your VCS.

### Javascript Specifics

Javascripts can require other files so you don't have to explicitly include each file on your page. This is done with a comment at the top of the file of the format:

    //= require <file/to/require>

Where `file/to/require` is a location relative to any path in `Paste.config.js_load_path`.

Sometimes, javascripts can even require some css to be associated with them. To do this, there's a similar directive which is as follows:

    //= require_css <path/to/css>

This will cause `stylesheet_link_tag` to be invoke with the argument `path/to/css` with a call to `stylesheet_tags`

### Stylesheet Specifics

Stylesheets don't normally require other stylesheets, so Paste doesn't do much with that. If you do need that, I'd recommend looking at [compass](http://compass-style.org). More options are normally needed with stylesheets, however, like `:media`. You can supply this via:

    <% stylesheet 'print', :media => 'print' %>

This will invoke `stylesheet_link_tag` a separate time with the options `:media => 'print'`

## Behaviour

Paste uses `stylesheet_link_tag` and `javascript_include_tag` with a `:cache` option set to a hash of the included files. Normally this means that in production all files are concatenated together.

## Example

Assume that `app/javascripts/jquery.js` exists and we have these files:

#### app/javascripts/foo.js

    //= require <jquery>
    //= require <foo/bar>

    $(function() {
      $('#foo').fadeIn().html($['BAR_VALUE']);
    });

#### app/javascripts/foo/bar.js.erb

    //= require <jquery>

    $['BAR_VALUE'] = <%= Bar::BAR_VALUE %>;

#### app/views/foo/index.html.erb

    <% javascript 'foo' %>
    <% stylesheet 'foo' %>

    <div id='bar'>
      And the bar value for today is: <div id='foo'></div>
    </div>

For this example, whenever `foo/index.html.erb` is rendered, the stylesheet `public/stylesheets/foo` will be included and so will both `app/javascripts/foo.js` and `app/javascripts/bar.js.erb` with `bar` before `foo`.

## Configuration

The following are recognized options:

    Paste.configure do |config|
      config.root     # the root directory (defaults to Rails.root or the pwd)

      config.tmp_path # a temporary directory to use. Can be relative to the
                      # root or it can be an absolute path.
                      # Default: 'tmp/paste-cache'

      config.js_destination # relative or absolute path of where to put
                            # javascripts. Default: 'public/javascripts'

      config.js_load_path   # The load path for javascripts. This is where to
                            # find the source files.
                            # Default: ['app/javascripts']

      config.erb_path    # relative or absolute path of where to generate the
                         # ERB results to. Default: 'tmp/paste-cache/erb'

      config.parser      # The parser class to use when determining dependencies
                         # of javascripts. Default: Paste::Parser::Sprockets
    end

All configuration should be done in `config/application.rb` or `config/environments/*.rb`.

## License

Copyright 2011 Alex Crichton.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
