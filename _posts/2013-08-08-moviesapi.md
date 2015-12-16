---
title: "moviesapi: A Simple API for UK Cinema Listings"
published: 2013-08-08 13:40:00 +0000
tags: ruby, api, rest, young-rewired-state
---

This week has been [Young Rewired State][] week. At [YRS i-DAT][] in Plymouth, we've
had a team of five working on an tool to give you suggestions on what to do if you
were bored, all based upon your location.

Among lots of other data sources, they wanted a way to get nearby cinemas and the
times of films which were showing there. After a quick hunt around for different
sources, it looked a bit bleak. Back in 2009, Yahoo had a movies API. Google had
one too as part of iGoogle, but that went when iGoogle was shut down.

Then I came across [Find any Film][]. The first reference I could find for it was
a [2009 Guardian article][guardian], explaining how the [UK Film Council][] had
launched the site, and it mentioned that: "an API will also be rolled out that will 
allow developers to build applications around this unique and rich data set. 'We'll 
be thinking carefully about the best way of doing that.'". Sadly, it looks like this
never happened.

So, I took it upon myself to screenscrape Find any Film and spit out JSON formatted
data that could be reused by our YRS team. That became [moviesapi][].

It's a small collection of Ruby, with the parsing handled by [Nokogiri][] and the
API implemented using [Sinatra][]. It's very similar to my last screenscraping
project, [UrbanScraper][].

As it is now, it implements the ability to find cinemas based on a postcode and to
find out the show times today at a given cinema. This was just enough to get it
working for the team, but I'll probably add more functionality later on.

At some point, I need to add some tests[^tests], and it would be nice to run it
through [Travis][] too. Additionally, some caching (probably using Redis) would be
good &mdash; the requests are quite slow and don't change all that often.

The legal status of this data is a little complex. As far as I can understand, any
user (including me, and then you using the API) would be bound by the Find any Film
[Terms and Conditions][] which says that you cannot use the data commercially along
with a bunch of other things. It'd be nice if people would just share this kind of
data, but that's another complex argument. I'm of the opinion that I'll continue to
run such a thing (doing as much as I can to stop Find any Film being abused by
caching at my end) until I'm told otherwise.

Anyway, [the source is on GitHub][github] and the 
[live API is hosted on Heroku][moviesapi].

[^tests]: I'm not sure how to test screenscraping tools (UrbanScraper is in the same
    boat and also needs them). My thoughts fell along testing the existence of 
    returned data and their types.

[Young Rewired State]: http://youngrewiredstate.org/
[YRS i-DAT]: https://github.com/yrsIDAT/2013
[Find any Film]: http://www.findanyfilm.com
[guardian]: http://www.theguardian.com/media/pda/2009/jan/28/digitalmedia-digitalvideo
[UK Film Council]: http://industry.bfi.org.uk
[moviesapi]: http://moviesapi.herokuapp.com
[Nokogiri]: http://nokogiri.org/
[Sinatra]: http://www.sinatrarb.com/
[UrbanScraper]: http://urbanscraper.herokuapp.com/
[Travis]: http://travis-ci.org
[Terms and Conditions]: http://www.findanyfilm.com/terms-and-conditions
[github]: https://github.com/nickcharlton/moviesapi
