---
title: "Reserve: Caching with Expiring Keys and Redis"
published: 2014-10-12 00:00:00 +0000
tags: redis, ruby, caching
---

I've just released a new RubyGem which makes caching objects (and allowing
them to expire) in [Redis][] easy. It's called [reserve][] and the [source is
on GitHub][source].

This came from a desire to easily wrap common but slow tasks in a block that
would give me the advantages of caching but not increase the code complexity
significantly. We can do this by assuming that the output of most operations
could be serialised as JSON and then be thrown into a Redis instance. That means
that the simplest implementation could look like:

```ruby
reserve = Reserve.new(Redis.new)

item = reserve.store :item do
  { value: 'this is item' }
end
```

Here, `item` will be the hash object `{ value: 'this is item' }` that will be
generated and stored on the first call, then subsequent calls will be cached
in redis until they expire. By default, the expiry time is set to 10800 seconds
(3 hours). After it expires, it'll regenerate by executing the block again.

The need behind this project was in caching responses from commonly used screen
scraping tools. I wanted to be able to wrap the code that was already being
used for the scraping so that on subsequent requests this was reused for a
set period of time. Redis works great for this because we can easily store
data with [`SET`][set], and the expiry is also handled by Redis with
[`EXPIRE`][expire]. But there's lots of other operations which work well with
this sort of time-based caching.

With Reserve, the goal was to take those two Redis commands and have a very thin
layer between the application code and Redis. It should be possible to "wrap"
a variable assignment to add this sort of caching and not require all that
much more.

I also wanted to be able to support a wide range of Redis drivers and keep the
rest of the dependancies as low as possible. I think it fits these requirements
quite well.

Two places where this will be used are [UrbanScraper][] and [moviesapi][],
which I've been maintaining for a while.

You can [browse the code on GitHub][source], view on [RubyGems.org][reserve]
and also [read the docs at RubyDoc.info][docs].

[Redis]: http://redis.io
[reserve]: https://rubygems.org/gems/reserve
[source]: https://github.com/nickcharlton/reserve-ruby
[UrbanScraper]: http://urbanscraper.herokuapp.com
[moviesapi]: http://moviesapi.herokuapp.com
[docs]: http://rubydoc.info/github/nickcharlton/reserve-ruby/master/frames
[set]: http://redis.io/commands/set
[expire]: http://redis.io/commands/expire
