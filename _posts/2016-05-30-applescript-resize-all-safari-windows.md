---
title: "Resize all Safari windows with AppleScript"
published: 2016-05-30 12:17:12 +0000
tags: applescript automation
---

I have a particular preference for the size of my browser window, and I like
them all to be consistent. I divide my time between a 13" MacBook Pro and the
same device attached to a 27" Thunderbolt Display. Usually this works out
great, but over time, my browser windows will all end up being _slightly_
different. Some will be a bit shorter, some wider, some off
centre.

This is a pain to maintain manually, so in drops some [AppleScript][]. I can
reset all visible windows to be the same size (across all Spaces) and be
centred on the screen. This is my goal:

<figure>
  <img src="/resources/images/resized_safari_window.png"
  alt="Resized Safari Window" max-width="500px">
  <figcaption>Resized Safari Window</figcaption>
</figure>

Here's the AppleScript:

```applescript
set height to 575
set width to 1212

tell application "Finder"
    set screen_resolution to bounds of window of desktop
end tell

set screen_width to item 3 of screen_resolution
set screen_height to item 4 of screen_resolution

tell application "Safari"
    activate
    reopen
    set y to (screen_height - height) / 2 as integer
    set x to (screen_hidth - width) / 2 as integer
    set the bounds of every window to {x, y, width + x, height + y}
end tell
```

The first two variables are set the size I'd like the window to be (it's in
points). Over time, I'll adjust this, so it's best pulled out at the top.

The script then goes on to calculate the `x` and `y` positions according to the
current screen resolution (this ensures it's centred) and then applies this to
every window.

This is a reasonably simple script, but it took a while to figure out. Such is
the nature of AppleScript.

_Note: This doesn't support multiple displays. The reported `bounds` returned
for the desktop include all of the displays combined together. We'd need to
figure out which windows belonged to which display and then calculate it that
way. This is a reasonable shortcoming for my usage._

A script is great, but not the most convenient. For this, I turned to
[Alfred][] and put together a quick workflow to invoke it with: "Reset Safari
Windows":

<figure>
  <img src="/resources/images/resized_safari_window_workflow.png"
  alt="Resized Safari Window Workflow" max-width="500px">
  <figcaption>Resized Safari Window Workflow</figcaption>
</figure>

<a href="/resources/reset_safari_window_positions.alfredworkflow">You can
download the workflow here.</a>

[AppleScript]: https://en.wikipedia.org/wiki/AppleScript
[Alfred]: https://alfredapp.com
