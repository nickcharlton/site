---
title: Tweetbot Mute Filters
published: 2013-08-13T13:01:00Z
tags: tweetbot, regex, twitter
---

The other day, [I tweeted a link to a regex-based mute filter for Tweetbot][tweet].
The full URL looks like:

```
tweetbot:///mute/keyword?regex=1&text=(%3Fi)%23%3Fbreaking(%3F%3D%20%3Fbad)
```

It uses Tweetbot's URL scheme[^scheme], to provide a predefined mute filter. This
way, a filter can be shared without copy and pasting it, which is quite nice. In
trying to work out how to do this, I ended up browsing around Twitter trying to
find an example of how to pass along a regex in the URL, as I had seen it done 
before. As I imagine I'll do this again, I thought I'd write it up.

## Regex

Before it is encoded, the regex looks like this:

```regex
(?i)#?breaking(?= ?bad)
```

It's designed to match;

* "breaking bad"
* "breakingbad"
* "#breakingbad"
* "Breaking Bad"

and similar variations, but not;

* "breaking"
* "bad"

when used alone.

The first bit, `(?i)` sets the regex to be case insensitive. `#?` means it may or
may not start with a hash (matching hashtags or not). Then, the rest comprises of a
lookahead assertion.

A lookahead assertion tests to see if a given set of characters are followed by
another set. It's [considered an assertion because it doesn't consume these
characters][regex], it will only match them. For testing regular expressions, I use
[Patterns][], so you get something that looks like this:

<figure>
  <img src="/resources/images/bb-regex.png" alt="Testing in Patterns" width="500px">
  <figcaption>Testing in Patterns</figcaption>
</figure>

You will see that whilst this matches the appropriate lines, it doesn't match the
whole term. In this situation, this is fine (Tweetbot filters any tweet that would
match). So, `breaking(?= ?bad)` looks for the word "breaking" followed by "bad",
with or without a space between them. The lookahead assertion is the bit in
brackets, `(?=)`.

## Assembling the URL

The next bit is to make it valid inside a URL. I cheated and used Eric Meyer's
[URL Decoder/Encoder][encoder], but the invalid characters are below:

+-----------+-------------+
| Character | Replacement |
+===========+=============+
| ?         | `%3F`       |
+-----------+-------------+
| &#35;     | `%23`       |
+-----------+-------------+
| =         | `%3D`       |
+-----------+-------------+
| Space     | `%20`       |
+-----------+-------------+

There are obviously many tools to help do that bit.

So now, the next time I want to avoid spoilers to the finale of a pretty good TV
show, I'll be save in the knowledge that once, I wrote down how it did it.

[^scheme]: Many other iOS/Mac apps have a similar thing, it's a bit of a hack to
    have inter-application communication. [Macstories has a bunch of posts on 
    them][scheme].

[tweet]: https://twitter.com/nickcharlton/status/366705942739423233
[scheme]: http://www.macstories.net/tag/url-scheme/
[regex]: http://www.regular-expressions.info/lookaround.html
[Patterns]: http://krillapps.com/patterns/
[encoder]: http://meyerweb.com/eric/tools/dencoder/

