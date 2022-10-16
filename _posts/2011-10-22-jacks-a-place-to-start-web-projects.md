---
title: "Jacks: A place to start web projects"
tags: web development, jacks, responsive design
---

A couple of weeks ago, I started a project which intended to pull together all of the stuff that I had learnt about responsive design. I also wanted to have a generic starting point for web projects. I came up with Jacks, a simple web "framework" which does exactly that.

### Being Responsive

Responsive Design is all about providing one singular web experience that is optimal for many different devices. With the growth of what some call the "mobile web", you've probably come across some horrible web experiences.

I believe that we should present an optimal experience for as many browsers, in as many situations, as possible. 

Jacks uses a fluid grid which is tamed with the use of media queries. It's very much based around the work done by [Ethan Marcotte](http://unstoppablerobotninja.com/), in his book, "[Responsive Web Design](http://www.abookapart.com/products/responsive-web-design)". If you're interested in this at all, I urge you to go ahead and read it. It does a much better explanation than I could ever aim to do. 

### Jacks Gives

So, what does this actually do? Jacks provides you a bunch of presets to work off of.

These presets include:

* Some default libraries:
	- Eric Meyer's CSS Reset
	- jQuery
	- LESS CSS
* An example HTML page to start off with.
* Some basic CSS styles for:
	- Typography
	- Colours
	- Common Effects (shadows, rounded corners, etc)
	- Flexible Media Blocks (aka, max-width: 100%)
	- Media Queries for common display sizes.

It uses [LESS](http://lesscss.org/) to make CSS easier and more maintainable.

Jacks uses media queries to tame the fluid grid. The default layout is assumed to be approximately 960px (which you've probably already been doing), then it provides increasingly smaller steps until a much larger block for handling large browser windows (>1200px).

I call this the upside-down triangle on a shelf method. I find it works quite well.

### [GitHub](http://github.com/nickcharlton/jacks)

Like most of my projects, [it's up on GitHub](http://github.com/nickcharlton/jacks). It's licensed under the MIT license. I intend to improve and adjust this as I go.

I encourage you to fork and add your own changes. Do a pull request if you want it to be pushed up into the main repository.

It's been used in one production project so far. I'd certainly be interested in hearing if it's used elsewhere!

