---
title: "Building a Brew Fridge"
tags: project brewing
---

I started brewing beer about three years ago and got to the stage where I was
doing full-grain brewing and was really into it. But then I moved house and
…just stopped.

Over those past few years I've been living in two (broadly identical) draughty
old Victorian houses with nowhere appropriate to leave a fermenter in. With
these kind of houses, the temperature fluctuates massively throughout the day
and so the first brew was a bit of a disaster. It fermented _fine_ but just
didn't taste very good and eventually most of it went down the drain.

I wanted to take this environmental restriction out of the equation and had
read a lot about people converting fridges and freezers to control fermentation
temperature. Did it solve the problem? Yes! I'm now two successful brews in.
Here's what I did…

## Scope

Given a fridge and a heating element, the idea is to provide a temperature
regulated environment to store your fermenter.

This whole idea started with discovering the [BrewPi][2] way back when I
started brewing all of those years ago. The BrewPi allows you to control and
visualise the temperature with the combination of a bunch of relays and
thermocouples. It has a few guides and is presented as a nice looking product.
It's a very neat device, but it's also [quite expensive starting at about
€170][8].

I needed to reduce the cost, luckily the brewing community has shared lots of
alternative methods. This lead to searching for an off-the-shelf temperature
controller which would do a good enough job of maintaining the temperature in
a generic fridge. I didn't really need an extremely precise amount of
temperature control (not so much 0.1º, but 1º) because most recipes are in a
wide enough recommended temperature range and that visualising what was going
on would be nice, but not really needed.

This lead me to finding the [ITC-1000 and can be had for about £15][3]. The
downside with the ITC-1000 is that they still need a bunch of wiring work but
some more research lead to the [Inkbird ITC-308][4] which didn't. You plug in
your heater in one socket and the fridge into the other. Perfect.

## Choosing a Fridge

This left the biggest expense: a fridge.

I first looked at fridges back in 2018. My main concern was finding a model
that would definitely be big enough, as once you take into account not being
able to use the space around the hump (either because we need to put a heater
in there or because it takes up too much space) the space is quite restricted.
On top of this, it's quite hard to find fridges with as few features as
possible: similarly, we don't want an ice box as that too takes up valuable
space.

My first instinct was to try and reuse one, but not being able to pick one up
myself meant that buying a new one was cheaper. The modern world sucks
sometimes.

<figure>
  <img src="/resources/images/brew-fridge-old-fridge-research-image.jpeg"
    alt="Old Fridge Research" max-width="250px">
  <figcaption>Old Fridge Research</figcaption>
</figure>

In the end I settled on a [Currys Essentials CUL55W20][5], which at the time
worked out to be £139.99 with free delivery. This wasn't quite the cheapest
possible, but just about one up. The main difference here is the width, which
means a 30L fermentation bucket fits with room to spare, which with a slimline
one might not have quite worked out.

As I'd come back to this project a while after first starting, I'd realised
that the model number breaks down to be `55W`, meaning 55cm wide and `20` for
the model year. (If you look at the photos above, the model year is `18`). I
think `UL` is likely "undercounter larder".

I'd always traditionally used [bubbler airlocks][6], but these won't fit with
the amount of vertical space available. I picked up a few [cylindrical ones][7]
instead which do fit.

## Fitting a Heater and Temperature Controller

Now I had a fridge, it was time to work out what else I'd need. A big decision
I'd made early on was to make sure I could use the fridge as it was originally
intended if necessary (over Christmas 2020, it was full of potatoes and then
the turkey!) and so I didn't want cables just coming through the fridge wall or
to have to remove any material inside the fridge which would stop the shelves
being able to go back in.

Through a long-lost forum thread, I was inspired to install a waterproof socket
which would leave a surface mount on the back wall and also allow the heater to
be removed if I wanted to.

For the heater, I went with a [basic 60W tubular one][9] — typically used for
outside bathrooms or greenhouses. These come with a bare set of wires, as
they're designed to go into a fixed fused spur at 3A. I achieved the same thing
by installing a socket on one end to the same amperage.

The most difficult part of the whole project was working out where to drill the
hole for the socket. [I previously wrote about hiring a thermal camera][10]
and this project is really what it was for. For a less technical route, there's
a commonly cited method of vodka and corn flour (the idea being that the vodka
evaporates quickly, leaving dry cornflour to highlight the coolant lines) but
I didn't feel particularly confident with it. So I took a couple of thermal
images to confirm my suspicions of where might be good to drill a hole.

<figure>
  <img src="/resources/images/brew-fridge-thermal-image.jpeg"
    alt="Thermal image of the inside of fridge showing hot spots" max-width="250px">
  <figcaption>The inside of a switched on fridge through a thermal camera</figcaption>
</figure>

From looking at some product diagrams of fridges and then from looking at the
fridge itself, I figured that my best bet was to use the hump at the bottom.
This is there to provide a space for the compressor, pump and electronics for
the fridge without it sticking out the back. In addition to this, from looking
at the coolant lines which are visible, it was possible to see these go up into
the back of the fridge (and so above where I wanted to drill). You can see this
happening in action on the thermal image below:

<figure>
  <img src="/resources/images/brew-fridge-thermal-image-fridge-rear.jpeg"
    alt="A thermal image showing the hump at the back of a fridge giving off
    heat" max-width="250px">
  <figcaption>
    Thermal image showing the hump at the back of a fridge giving off heat
  </figcaption>
</figure>

This left drilling the actual hole. First, I drilled a 5mm pilot hole through
the outer layer of plastic, then pushed through a long piece of stiff wire to
break through all of the insulation. This ensured I wasn't about to hit
something I didn't want to and that the exit hole also wouldn't hit the
compressor. After this, I used a step drill to go through wide enough to get
the 23mm hole required by the socket. I found the insulation to be much thicker
than you'd expect (which I suppose is not surprising!), but it's easy to get
through as it's just foam. You can broadly see the process in the photos below.

<figure>
  <img src="/resources/images/brew-fridge-pilot-hole.jpeg"
    alt="A photo showing the base of a fridge, with a pilot hole with wire
    coming through" max-width="250px">
  <figcaption>Pilot Hole, with wire to breach the insulation</figcaption>
</figure>

<figure>
  <img src="/resources/images/brew-fridge-drilling.jpeg"
    alt="A photo showing the main hole being drilled" max-width="250px">
  <figcaption>Drilling the main hole</figcaption>
</figure>

<figure>
  <img src="/resources/images/brew-fridge-heater-flex.jpeg"
    alt="A photo showing the heater wire being passed through" max-width="250px">
  <figcaption>Passing through the heater wire</figcaption>
</figure>

<figure>
  <img src="/resources/images/brew-fridge-installed-socket.jpeg"
    alt="A photo showing the installed socket" max-width="250px">
  <figcaption>Socket installed</figcaption>
</figure>

The socket is from [the Elkay waterproof range which I got from Rapid
Electronics][11], I paired this with some [0.75mm² flex][12] which is the same
as used on the heater. The heater itself is relatively generic and just big
enough to cover most of the area at the bottom of the fridge at about 50cm.

<figure>
  <img src="/resources/images/brew-fridge-installed-heater.jpeg"
    alt="A tubular heater in the base of a fridge" max-width="250px">
  <figcaption>The tubular heater installed in the fridge</figcaption>
</figure>

Then the fridge and heater are plugged into the temperature controller. Some
advice I'd seen on the Amazon listing for the controller was to set the
thresholds to 0.5º for the fridge and 1.0º for the heater. The thermal mass of
the fermenting bucket will slow down any temperature changes, but this should
stop the fridge cycling on and off too often and shortening the life of it.

Finally, I built a platform out of some bits of old wood. Cut wide enough and
then the edges thinned to slot into the place where the glass originally was,
the fermenter sits on top of these.

<figure>
  <img src="/resources/images/brew-fridge-with-fermentation-bucket.jpeg"
    alt="A modified fridge, showing the fermentation bucket fitting well" max-width="250px">
  <figcaption>The fridge with everything installed and setup</figcaption>
</figure>

Overall, the project (including specific tools) came to £236.89, broken down
into:

| Item | Cost |
|:--|:--|
| [Currys Essentials CUL55W20 Undercounter Fridge][5] | £139.99 |
| [Inkbird ITC-308 plug-in temperature controller][4] | £35.98 |
| [60W 1' Tubular Heater][9] | £20.99 |
| [Reel of 0.75mm² flex (you really only need about 2M!)][12] | £13.49 |
| [13A Plug][13] | £0.93 |
| [Pack of 3A fuses][14] | £1.90 |
| [Step Drill Set][15] | £11.99 |
| [Elkay 3 Pole Waterproof Socket][16] | £5.52 |
| [Elkay 3 Pole Waterpoof Plug][17] | £6.18 |

## Future Expansion

For the first brew, I just taped the temperature probe to the outside of the
fermenter. I wasn't brewing a beer which is very temperature sensitive (a
bitter close to Fuller's ESB) and so I didn't need to worry too much about the
extra degrees given off by the fermenting process.

But for the second, I installed a thermowell — a device which allows the probe
to be isolated from — but still inside — the bucket. [I got this one from The
Malt Miller][1], which whilst a bit pricier (at £18) did actually have
everything required in one purchase and so I didn't need to hunting around for
washers or the right nut to fit.

For now, this is the last of the modifications. It works great as it is and if
I wanted to do multi-day temperature changes that's absolutely possible. In the
future, it might be interesting to add a BrewPi Spark but this is definitely
Good Enough™.

_Thanks to [Luke Mitchell][18] for looking at a draft_

[1]: https://www.themaltmiller.co.uk/product/thermowell-stainless-100mm-weldless/
[2]: https://www.brewpi.com
[3]: https://www.amazon.co.uk/dp/B00IJ0F2OW
[4]: https://www.amazon.co.uk/dp/B018K82UQU
[5]: https://www.currys.co.uk/gbuk/household-appliances/refrigeration/fridges/essentials-cul55w20-undercounter-fridge-white-10205941-pdt.html
[6]: https://www.themaltmiller.co.uk/product/bubbler-airlock/
[7]: https://www.themaltmiller.co.uk/product/cylindrical-airlock/
[8]: https://store.brewpi.com/featured/brewpi-spark-3
[9]: https://www.amazon.co.uk/dp/B00L41ZVBW
[10]: /posts/a-weekend-with-a-flir-one.html
[11]: https://www.rapidonline.com/brands/elkay?Tier=Weatherproof%20Connectors
[12]: https://www.screwfix.com/p/time-3093y-white-3-core-0-75mm-flexible-cable-25m-drum/177jy?_requestid=582403
[13]: https://www.screwfix.com/p/diall-13a-fused-plug-white/5751h?_requestid=587427
[14]: https://www.screwfix.com/p/3a-fuse-pack-of-10/94488?_requestid=587599
[15]: https://www.amazon.co.uk/dp/B089QM2W29
[16]: https://www.rapidonline.com/elkay-1851e1000s0301-aqua-safe-screwed-waterproof-3-pole-male-housing-socket-23-1494
[17]: https://www.rapidonline.com/elkay-1850a1011p0301-aqua-safe-in-line-waterproof-3-pole-female-housing-plug-23-1480
[18]: https://interroban.gg
