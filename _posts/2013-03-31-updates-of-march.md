---
title: Updates of March
tags: blog, updates
---

In which I document some changes I made around here…

To start with, I've adjusted the leading, measure and font size to make it a little
easier to read. This was partly motivated by [Dan Barber's talk][talk] at [Digpen VI][]
I also rebalanced the header, but unless you visited in the last few days, you won't
notice.

Secondly, I added a "Link" section. I intend to link to things I come across every 
so often, sometimes with a bit more than a line of commentry. You'll see more when 
I read longer and more indepth things.

It's in the same Atom feed (and on the homepage) but implemented as a seperate
directory. I might do something more with it in future. But you will see it displayed 
differently on the site itself; it'll always have a "&rarr;" and the post metadata 
will say "Linked on `<date>`", rather than "Posted on `<date>`".

This is implemented in the same way as posts, but to provide both (posts and links)
to the index page and atom feed, I'm using a regex, like so:

```haskell
setFieldPageList (take 3 . myChronological) 
    "templates/post_full.html" "posts" (regex "^(posts|links)/")
```

(where take 3 . myChronological is a sorts differently than the default, the
template string is where it renders to and "posts" is in the infull.)

I should move to Hakyll 4 and no doubt it'll be easier than I expect; but I'm 
waiting until I finish the write up part of my degree. Also known as the next few 
weeks.

And of course the last two posts make up some of the stuff I'll start writing up
from my project, a retrospect over a month, maybe.

[talk]: https://speakerdeck.com/danbarber/design-eye-for-the-developer-guy
[Digpen VI]: /posts/digpen-vi.html

