---
title: Site v4
published: 2014-08-20T11:42:00Z
tags: site, release
---

If you're reading this, it means that I successfully rolled-out the fourth[^1]
version of this site. It's a small set of changes from before, but there is a
new style which accompanies a simpler design.

On the design side, I wanted to deemphasize the latest set of posts (they're
not, and never have been time dependent) and instead have it as a short
representation of me. Thus the blurb on the homepage. I also wanted to remove
the dedicated pages of static content (About, Projects, etc) which sets up for
having large amounts of text that doesn't get updated (and, I suspect, people
don't really want to read through).

The project page does stay, but presented in a simpler manner and refreshed
with more recent ones. But the experiment with having a "links" section has
gone (those posts have been pushed into the posts).

On the implementation, I've chopped out [SASS][] because it's mostly
unnecessary with so few styles and the amount of templates could also go down.
But, I did have to [implement a few changes to add support for HTML definition
lists][definition_lists].

And so, the site is updated for another year.

[^1]: Sadly I'm not sure what the actual version should be, so I'm going with
      how long I've had a "modern" iteration of it. I've been reworking this
      every year for the past four and so this seemed to fit well.

[SASS]: http://sass-lang.com
[definition_lists]: /posts/custom-pandoc-options-hakyll-4.html
