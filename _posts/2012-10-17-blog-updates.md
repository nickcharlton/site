---
title: Blog Updates
tags: blog, personal
---

For a project several weeks in the making, I've just pushed up the changes to
this, my site. I started working on all of this way back when I was still on
placement, but then also through Young Rewired State and intermittently
since. It's been at once the bane of my todo list, and a joy to work on,
experimenting, refactoring and of course, writing.

It's in no-way perfect, but it's a significant improvement from my orignal
version.

Like most of my projects, it's also up on
[GitHub](https://github.com/nickcharlton/nickcharlton.net).

## Posts

There's a few posts which I've finally been able to post. Most of these had
been sat around as drafts, others needed a bit of completion. But, without
further ado, my last few months:

* [NSConf Mini: Developers vs. Designers](/posts/nsconf-mini.html)
* [dConstruct 2012](/posts/dconstruct-2012.html)
* [Young Rewired State 2012](/posts/young-rewired-state-2012.html)
* [Finishing at Rokk Media](/posts/finishing-at-rokk-media.html)

I'm now a good few weeks into the final-year of my degree and so my focus has
(necessarily) shifted quite a bit. My focus from now on will be mostly centred
around [Python](http://python.org/), [Qt](http://qt.digia.com) 
(using [PyQt](http://www.riverbankcomputing.co.uk/software/pyqt/intro) and 
some OpenGL), Robotics, 
[GPU Computation using CUDA](http://www.nvidia.com/object/cuda_home_new.html) and
various AI topics. I already have a few drafts relating to these in the works
(I find it a great way to learn). I will also be occasionally posting about my
degree project &mdash; a Quadrotor platform, Simulator and associated mapping
algorithms. It's going to be an interesting year.

## A Colophon

This version is based upon [Hakyll](http://jaspervdj.be/hakyll/index.html). 
It's a static site generator written in Haskell. Before this, I tried out multiple 
others, from [Hyde](http://hyde.github.com/) to
[Mynt](http://mynt.mirroredwhite.com/), and the original, 
[Jekyll](https://github.com/mojombo/jekyll). But each had issues in one sense or 
another and didn't work all that well for me. Obviously, your requirements will 
vary.

But, the key part of Hakyll is it's use of
[pandoc](http://johnmacfarlane.net/pandoc/). This is a document
conversion tool (also written in Haskell) that I've since started using for
generating documents for print. It also had the
[Markdown](http://daringfireball.net/projects/markdown/) extensions that
I wanted (footnotes, citations, LaTeX maths support, tables, etc.)

The design itself is responsive[^responsive] &mdash; albeit, not tested absolutely
everywhere &mdash; but not mobile first (because I'd written it desktop first),
I'll probably fix this at some point.

It uses TypeKit to provide "Proxima Nova" for headings, and "Adelle" for the
body text. The icons are font-icons from [Pictos Server](http://pictos.cc/server).

Syntax highlighting is provided in `<pre>` and `<code>` blocks using
[Pygments](http://pygments.org/).
Mathematics symbols are through [MathJax](http://www.mathjax.org/).

It's deployed by pushing a Git repository to a VPS hosted with
[Prgmr.com](http://prgmr.com/), which I've used for several years now.

[^responsive]: People who aren't building sites this way should be shot, even
for side projects like this.

