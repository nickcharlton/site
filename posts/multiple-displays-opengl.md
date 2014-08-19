---
title: Multiple Displays (and OpenGL)
published: 2013-07-06T15:30:00Z
tags: link
---

Something I've not seen anyone comment on is the reasoning behind why Apple have
put off Multiple Displays &mdash; like the way Mavericks implements them &mdash; for
so long.

My hunch is OpenGL. Apple has a custom implementation of OpenGL which extends well
into the way in which Cocoa and Cocoa Touch are implemented. On the Mac and on iOS
everything is OpenGL. Mavericks *finally* brings us OpenGL 4.1, thus bringing the
Mac up to speed with both the Linux and Windows implementations.

I assume that this was part of the reason. I imagine Mavericks brings us a much
improved graphics stack and that this significant change (which bought in OpenGL 4.1)
is also the reason why Apple decided to make a big change to multiple display
support.

Of course, all of this is because of the impending new Mac Pro &mdash; there's
little point shipping a cool GPU configuration if we're still writing graphics code
from 2009.

[But, as Thomas Brand says:][post].

> How long we have waited.

Indeed.

Regarding the new Mac Pro, I, [like Guy English, can also see cool new applications
of the hardware configuration][guy].

[post]: http://eggfreckles.net/notes/multiple-displays/
[guy]: http://kickingbear.com/blog/archives/349

