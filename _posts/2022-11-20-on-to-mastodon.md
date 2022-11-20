---
title: "On to Mastodon"
tags: mastodon
---

I'm now using Mastodon: [`@nick@nickcharlton.net`][1].

Some time ago, I stopped contributing on Twitter as much as possible. I was
still obsessively scrolling and using it to keep up with stuff going on, but I
was finding people elsewhere, ideally through subscribing to people's blogs via
RSS. I limited myself to occasionally liking tweets (I'd always used this as
bookmarking for later and the occasional DM for meeting up with people at
events, too).

As [Twitter seemed to be starting a terminal decline][3], I thought this was
great, and I'd not bother trying to replace it with something else. Maybe
finally I'd lose the thing I find myself obsessively scrolling every day.

But two weeks ago, I changed my mind. I always thought Mastodon was quite neat,
but if not enough people I'm following on Twitter started to use it, it was
always a bit moot. [Over the last few weeks, this changed][4] and [lots of
people started joining][2].

I feel strongly about retaining control over the things you produce. For
example, this site uses [Netlify][5]. Still, I have control over the domain and
moving it elsewhere is relatively trivial, if not just a little annoying if I
have to in a hurry. But if I did, nothing significant would change for those
visiting or reading many of the things I have written over the years. [If I
could run Mastodon myself][12], it was probably worth the effort if it was
going to take off.

None of this was happening in isolation. With [Heroku's slow death][6] and then
the [removal of their free plan][7], I was already migrating off the old and
onto the new. Some of my projects have gone to [Fly][10], but I have access to
a bunch of Azure credits, and I was keen to try and spin up a Kubernetes
cluster there as it's [been a long time since I tried to do that][11].
[Mastodon is a Rails app][8], after all, and I'm [quite familiar with
those][9].

I plan to write up a lot of the configuration (it did take me about two weeks
to get to this point, fitting in bits here and there), but I make a lot of
notes as I go along. [But join me on Mastodon, maybe?][1]

[1]: https://mastodon.nickcharlton.net/@nick
[2]: https://www.hughrundle.net/home-invasion/
[3]: https://ez.substack.com/p/the-fraudulent-king
[4]: https://adactio.com/journal/19650
[5]: https://www.netlify.com
[6]: https://xeiaso.net/blog/heroku-devex-2022-05-12
[7]: https://xeiaso.net/blog/rip-heroku
[8]: https://github.com/mastodon/mastodon
[9]: https://thoughtbot.com
[10]: https://fly.io
[11]: https://nickcharlton.net/posts/kubernetes-terraform-google-cloud.html
[12]: https://til.simonwillison.net/mastodon/custom-domain-mastodon
