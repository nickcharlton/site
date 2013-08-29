---
title: Alfred Workflow: Paste Cleanly
published: 2013-08-27T13:10:00Z
tags: alfred, regex, ruby
---

There is nothing more annoying than seeing, or ending up sharing URLs that look like
this (it's split so it doesn't look completely terrible…):

```
http://www.nytimes.com/2013/08/25/opinion/sunday/ \
im-thinking-please-be-quiet.html? \
ref=opinion&_r=3&utm_source=buffer&utm_campaign=Buffer
&utm_content=buffer8fcfe&utm_medium=twitter&
```

It's not so much the efforts of marketing people to track how their URLs spread
around the web that annoys me, but more that it's so damn ugly and far too long. 
But it is also happens to be the case that I don't particularly care about 
marketing people's feelings by me removing them.

I'm already an avid user of [Alfred][], where I use one of the example workflows to
allow me to use "Cmd + Shift + V" to paste as plain text. I figured the addition of
a little "cleaning" script based on a regex would be a nice way to implement it, so
I did[^check].

Jump to the end if you're just looking for the workflow.

## Regex and Test Pattern

The Google Analytics arguments all start with "utm_" (presumably standing for the
original Urchin product name). This is quite easy to match:

```regex
(?i)(?:utm_+)[a-zA-Z]*=[a-zA-Z0-9]*(&)?
```

This searches for "utm_", a collection of other characters until an =, then another
collection of characters until either the end is reached, or it walks into an "&".
It also does this case insensitively.

This will correctly match/remove the offending string from all of the URLs below:

```
http://example.com/slug?utm_content=test
http://example.com/slug?another=yep&utm_content=test
http://example.com/slug?utm_content=test&required=true
```

I was originally also matching either a `?` or `&` at the start and removing that,
too. But, with the last example (which, actually, I haven't seen in the wild), this
could potentially break the URL. Instead, I'm checking for a lost `?` on the end of
the URL before passing it back.

And so, the workflow's regex implementation:

```ruby
input = '{query}'

# remove any matching Google tracking strings
input.gsub!(/(?i)(?:utm_+)[a-zA-Z]*=[a-zA-Z0-9]*(&)?/, '')

# if there's a trailing ?, remove it
if input.end_with? '?'
  input.chop!
end

# pass it back, without the newline
print input.strip
```

## Alfred Workflow

The workflow is based on the "Paste as plain text from hotkey" example, which I
already had mapped to "Cmd + Shift + V". I'm just slotting through a "Run Script"
action before it is pasted.

<figure>
  <img src="/resources/images/pastecleanly_workflow.png" alt="The Paste Cleanly Workflow.">
  <figcaption>The Paste Cleanly Workflow.</figcaption>
</figure>

You can [download an archive of the workflow here][workflow].

And so, there we go. As I get offended by more web-based atrocities[^strong], I'll
likely add to the script more.

[^check]: Something similar might already exist. It was quicker for me to build it
    myself, than search the forums to see if someone else had done it already. But,
    I suppose, this is rendered a bit moot now I've written a blog post on it.
[^strong]: Yeah, I know. That is a bit strong.

[Alfred]: http://alfredapp.com/
[workflow]: /resources/pastecleanly.alfredworkflow
