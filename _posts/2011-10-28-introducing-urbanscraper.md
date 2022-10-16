---
title: Introducing UrbanScraper, and an Alfred Extension
tags: alfred, ruby, web-services, urban-dictionary, urbanscraper
---

Over the last two evenings, I've been working on a little toy. Well, two. The first one is a web service for getting definitions from [Urban Dictionary](http://urbandictionary.com) and the other is an Alfred Extension to allow you to get those definitions using your keyboard.

## [UrbanScraper](http://urbanscraper.herokuapp.com/)

It lead from a conversation with someone where I ended up having to reference some stuff a few times, I have a terrible memory for abbreviations and acronyms. I wanted to be able to find the definitions using Alfred, but Urban Dictionary didn't have an API.

Apparently, there used to be an API (albeit, SOAP), and there appeared to be other stuff around, but I figured I'd take a hack at it myself.

UrbanScraper scrapes the definitions (on demand) from Urban Dictionary and outputs simple JSON for you to use. It mostly uses XPath.

It's not exactly speedy (XPath isn't terribly fast), but it does the job with very little code. I've put it up on [GitHub](http://github.com/nickcharlton/urbanscraper). For the time being, it's hosted up on Heroku.

_For the love of god, please don't use this as an example of how to build Sinatra/Ruby apps, how to do Screen Scraping, or how to build RESTful Web Services. It was hacked together pretty quickly._

## The Alfred Extension

[You can download the extension here](/resources/urban_dictionary.alfredextension). Obviously, you'll need [Alfred](http://alfredapp.com) and the [Powerpack](http://www.alfredapp.com/powerpack/) to use it. But damn, is it worth it.

It's setup with the keyword `urban`. Passing something like "zomg" will give you a Growl notification containing: "zOMG is a variant of the all-to-popular acronym "OMG", meaning "Oh My God". The "z" was originally a mistake while attempting to hit the shift...".

It (like UrbanScraper), just grabs the first result. So it might not always be very good.

[Shout](/about) if anything breaks. 

