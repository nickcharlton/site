---
title: Mocking Web Requests with VCR and MiniTest
tags: ruby, testing, minitest, moviesapi, screenscraping
---

I just released [moviesapi][]. In [the post I introduced it][post], I mentioned 
wanting to be able to add reliable tests. [Ben Keeping][] responsed suggesting that 
I have a look at [VCR][]. So I did. 

It's a Ruby library that records the web requests that your application depends 
upon and saves it down to disk. On subsequent test runs, it reuses ("replays") the 
previously saved data, vastly increasing the speed. For screenscraping tools like 
[moviesapi][] or [UrbanScraper][], I can verify that my code is behaving correctly, 
even if the source has changed (this is another problem) and without constantly 
hitting the remote web service.

Tutorials covering both VCR and MiniTest were a little thin on the ground, so I
thought I'd write one. As an introduction to MiniTest, I'd suggest [Matt Sears'
Quick Reference post][quick_ref]. I'd also suggest giving the [VCR README][vcrdoc] 
at least a skim read.

The overall application I'm testing is a [Sinatra][] one, but here, I'm more
interested in testing the class that handles the screenscraping. Some of the
[MiniTest suggestions came from the Sinatra Recipes site][recipes].

## Gemfile

Firstly, I added development and tests groups to my Gemfile, like so:

```ruby
group :development, :test do
  gem 'minitest', '~> 5.0.6'
  gem 'webmock', '~> 1.12.0'
  gem 'vcr', '~> 2.5.0'
end
```

VCR is a high-level wrapper around a group of different web mocking libraries,
`webmock` is just one of those supported. We'll need this too.

MiniTest is actually already in the standard library from Ruby 1.9, but I'm keeping
a reference for clarity (and a slightly newer version).

## Spec Structure

I'm writing specs here, so everything is in a directory named "`spec`":

```
spec/
    cassettes/
    support/vcr_setup.rb
    spec_helper.rb
    movie_spec.rb
```

`cassettes` holds the recorded requests. `vcr_setup.rb` contains VCR configuration
(it's loaded by `spec_helper.rb`). `spec_helper.rb` sets up the tests and provides
any common configuration. Finally, `movie_spec.rb` is the spec I'll be running. 
It's from [moviesapi][].

### `vcr_setup.rb`

```ruby
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
end
```

This specifies where to find the cassettes &mdash; we assume everything is run from
the root of the project. Then it specifices which mocking library to use, in this
case, `webmock`.

### `spec_helper.rb`

This contains common code to all of the specs (or tests). It's typically used to 
load in the application and run any common load configuration (like setting `ENV` 
to `test`) and is then included in each spec (or test) to make it available on test
run.

```ruby
require 'minitest/autorun'
require 'minitest/pride'

# pull in the VCR setup
require File.expand_path './support/vcr_setup.rb', __dir__

# pull in the code to test
require File.expand_path '../movies.rb', __dir__
```

### `Rakefile`

Finally, these additions to the `Rakefile` will allow your tests to be running
according to typical Ruby conventions. It will also run the test suite as the
default rake task:

```ruby
require 'rake/testtask'

Rake::TestTask.new :spec do |t|
  t.test_files = Dir['spec/*_spec.rb']
end

task :default => :spec
```

For all of these helper files, they have been slimmed down a little. You may find
the [ones in the repo more helpful][moviesapi]. (Also, these will work with Travis
CI.)

## Writing Specs that use VCR

A typical MiniTest spec looks a bit like this:

```ruby
describe 'Something' do
  before do
    # something that should be done before a test starts
  end

  after do
    # something that should be done after a test ends
  end

  it 'does something' do
    # test things
  end
end
```

The MiniTest DSL provides several blocks that make up the spec. The `describe`
block defines the behaviour you are specifying. The `it` block defines the test
case. Then, inside here, "matchers" are used to confirm the output. MiniTest
[provides a reasonable collection of these in it's docs][assertions], but you can
also define your own[^gist].

When using VCR with MiniTest, [there are two approaches to work with][vcr_wiki].
The first is to manually specify a cassette to encapsulate the test run. This is
[described in the VCR Getting Started Guide][vcr_gs] and looks a bit like this:

```ruby
VCR.use_cassette('cassete name') do
  # the test
end
```

The second approach is to use the `before` and `after` blocks along with some 
runtime metadata that MiniTest provides. That looks a bit like this:

```ruby
describe 'Movies' do
  before do
    VCR.insert_cassette name
  end

  after do
    VCR.eject_cassette
  end

  it 'fetches a list of cinemas' do
    # the test
  end
end
```

`before` and `after` are executed around each `it` block. So here, `name` is 
"fetches a list of cinemas". If you were to have multiple `it` blocks, cassettes 
would be defined for each. The cassettes are then saved in `spec/cassettes`, in 
this case it is: `test_0001_fetches_a_list_of_cinemas.yml`. This is quite a nice 
approach for having a cassette dynamically defined for each spec.

For testing the result of the screenscraping, I have been checking the contents of 
the eventual data structure. Unlike with a typical web service, I can't check the
data that is contained within. Similarly, the cassettes are commited to the
repository because I am checking for the behavioural correctness of my code &mdash;
not that the web service/site has changed and broken it. For testing the behaviour
of code that depends upon this, mocking will fit perfectly.

MiniTest combines with VCR quite nicely &mdash; especially once you work out the
conventions to follow for structuring the test suite. If not for anything else,
mocking out the web requests like this saves a signficant amount of time when testing
web service interaction.

[^gist]: This gist by Jared Ning [contains a good set of examples of defining your 
    own][gist].

[moviesapi]: https://github.com/nickcharlton/moviesapi
[post]: /posts/moviesapi.html
[Ben Keeping]: https://twitter.com/benkeeping/status/365472072467628035
[VCR]: https://github.com/vcr/vcr/
[UrbanScraper]: https://github.com/nickcharlton/UrbanScraper
[quick_ref]: http://mattsears.com/articles/2011/12/10/minitest-quick-reference
[vcrdoc]: https://github.com/vcr/vcr/
[Sinatra]: http://sinatrarb.com/
[recipes]: http://recipes.sinatrarb.com/p/testing/minitest
[vcr_wiki]: https://github.com/vcr/vcr/wiki/Usage-with-MiniTest
[assertions]: http://docs.seattlerb.org/minitest/Minitest/Expectations.html
[vcr_gs]: https://www.relishapp.com/vcr/vcr/v/2-5-0/docs/getting-started
[gist]: https://gist.github.com/ordinaryzelig/2032303
