---
title: Jekyll and GitHub
tags: jekyll github blogging
---

After quite a bit of work, I have finally moved over to using GitHub pages, Jekyll and Markdown to power [nickcharlton.net](http://nickcharlton.net "nickcharlton.net").

From now on, this is a Git repository made up of Markdown files and a sprinkling of HTML. This comes with quite a few benefits, those of which I hope to explain below.

### Versioning & Backup

As it is powered primarily by Git, each post has version tracking without any extra effort. This was recently added to Wordpress, instead of a clean solution, this just turned to make the database even more of a mess than it already was.

Secondly, due to the distributed nature of Git, I always have two copies. One is served up at GitHub, and the other is my working copy stored locally on my main machine. On top of this, other people can fork it, adding more backups.

### Security & Access

Without the intention of using this primarily as a vehicle for moaning about Wordpress, this is another of it's issues. Certainly the two most important issues are security and access to the content.

As is typical with any large dynamic project, it's going to have security issues. This means that new versions of Wordpress are routinely rolled out, this means that you need to keep up-to-date with the latest build to keep your writings safe. 

Next, is access of the posts themselves. They're stored in a MySQL database. This both means that accessing the individual posts requires accessing the database, rather than just opening a file. Opening a flat HTML file will always scale better than a solution which involves reloading the same information from a database on each connection (presuming no caching is used).

### The Source

You can find the source on [GitHub](http://github.com/nickcharlton/nickcharlton.github.com). Please feel free to reuse any parts which are not posts without attribution. The posts themselves are licensed under a Creative Commons Attribution-Non-Commercial-Share Alike license. You can read more about that in the [README](http://github.com/nickcharlton/nickcharlton.github.com/blob/master/README.markdown).

