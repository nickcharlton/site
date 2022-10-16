---
title: Static Sites with Rack and Sass
tags: ruby rack sass
---

[Rack][] is the (excellent) common denominator web library for Ruby. [Sass][]
also happens to be written in Ruby. Combining the two can be the perfect
solution to building [Living Styleguides][], especially if you’re providing
them as an Gem.

I did this on a recent project, but the documented combination of the two was a
bit lacking.

### Static Sites with Rack

Rack is very barebones (it's usually used behind the scenes in [Sinatra][] or
[Rails][]), but it does provide `Rack::Static` which provides much of what
we'll want to do.

Following typical Ruby conventions, we'll end up with a directory structure
which looks like:

```
.
├── Gemfile
├── config.ru
└── public
    ├── index.html
    └── stylesheets
```

```ruby
# Gemfile
source 'https://rubygems.org'

gem 'rack', '~> 1.6'
```

```ruby
# config.ru
require 'rack'

use Rack::Static, urls: ['/stylesheets'], root: 'public'

run lambda { |_env|
  [
    200,
    {
      'Content-Type' => 'text/html',
      'Cache-Control' => 'public, max-age=86400'
    },
    File.open('public/index.html', File::RDONLY)
  ]
}
```

And then it can run with: `bundle exec rackup`.

This will serve `public/index.html` when called at: `http://localhost:9292` and
also serve the files in `public/stylesheets`. You can replicate that for other
directories (e.g.: for javascript).

### Adding Sass Support

Sass comes with a Rack plugin that makes this easy. The difficulty is in
handling the paths for the source data. Adjust the above to look something like
this:

```
# Gemfile
source 'https://rubygems.org'

gem 'rack', '~> 1.6'
gem 'sass', '~> 3.4'
```

```
# config.ru
require 'rack'
require 'sass/plugin/rack'

use Sass::Plugin::Rack

use Rack::Static, urls: ['/stylesheets'], root: 'public'

run lambda { |_env|
  [
    200,
    {
      'Content-Type' => 'text/html',
      'Cache-Control' => 'public, max-age=86400'
    },
    File.open('public/index.html', File::RDONLY)
  ]
}
```

The Sass plugin will assume it's stylesheets are in `public/stylesheets/sass`
and compile them to `public/stylesheets`.

In my case, I was overriding this by doing (which is the current recommended
way):

```ruby
Sass::Plugin.add_template_location('app/assets/stylesheets')
use Sass::Plugin::Rack
```

This adjust the source directory for the Sass files, and in this case follows
along with the standard Rails convention for them. This is because it's
structured to behave as a [Rails Engine][].

[Rack]: http://rack.github.io
[Sass]: http://sass-lang.com
[Living Styleguides]: https://gdstechnology.blog.gov.uk/2014/12/11/govuk-living-style-guide/
[Sinatra]: http://www.sinatrarb.com
[Rails]: http://rubyonrails.org
[Rails Engine]: http://guides.rubyonrails.org/engines.html
