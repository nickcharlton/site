---
title: "Switching to FeedBin and NetNewsWire"
published: 2021-11-21 16-50-50 +00:00
tags: rss tools
---

I've been using FeedWrangler and Reeder since [Google Reader][2] shutdown. All
of these years they've continued to work really well. But I've wanted to move
back to NetNewsWire since it was taken back over by Brent Simmons and made Open
Source.

NetNewsWire was always more of a "Mac app" than Reeder ever intended to be,
which played around with new UI ideas and helped push along some of the more
innovative patterns we see today. But two things always bugged me:

1. It has no feed organisation, you just have one long list of unread items,
2. The swipe gesture and I never really got along as I'd accidentally jump
   around whilst reading,
3. The keyboard shortcuts always surprised me, being always slightly different

NetNewsWire solves all of these. But it doesn't support FeedWrangler.
FeedWrangler has been great; I jumped on it in the days when Google Reader
announced it was going to shutdown and the frenzy of RSS syncing services
started up. But since those days, it's broadly stayed the same and is now in a
deliberate stagnant mode.

I use multiple devices and operating systems, so to switch to NetNewsWire, I
needed a different syncing service. I was keen on something that:

1. Restored the web reading experience from the days of Google Reader,
2. Something that would be around for a long time,
3. Supported NetNewsWire (…obviously)

I ended up picking Feedbin. It's [open source][1] so if I really needed, I
could host it myself. It's been around for ages and I could pay for it with a
reasonable monthly cost, so I felt reasonably confident it'd be around for much
longer. Plus, the web UI looked great.

But the most compelling feature to me was _Actions_. I use RSS in two ways: to
keep up with news, and to follow people's blogs. People's blogs are often
management or technical in nature and so if I read them a few months later it's
not a big deal. News isn't like that, and there's often regular stories I
immediately mark as read. With Feedbin's Actions, I could automate marking
stuff as read. That's wonderful.

{% picture /resources/images/feedbin-actions.png %}
  An example of Feedbin's Actions auto-mark as read feature
{% endpicture %}

Migrating was a bit of a challenge. I don't keep anything like RSS reader inbox
zero. Mostly recently, I've been avoiding it too, as it hasn't been working
well for me and reading email newsletters much more instead. At the start of
the migration, I had just about 600 unread items. These went back to 2018, but
most were quite recent. It was broadly a case of:

1. Skim the headlines and mark everything I didn't care enough about as read,
2. Push longer items to Instapaper for reading later,
3. Open shorter items, videos and everything I wanted to read properly in the
   browser,
4. Skim back through and mark more as unread,
5. End up with some short items to skim read

From here, I could export my list of feeds from FeedWrangler as an OPML file
and import that into Feedbin. Then install NetNewsWire everywhere.

I did this a few months ago and found myself getting excited about RSS again
and starting to stop the newsletters which end up in my email inbox get back
over to RSS!

[1]: https://github.com/feedbin/feedbin
[2]: https://en.wikipedia.org/wiki/Google_Reader
