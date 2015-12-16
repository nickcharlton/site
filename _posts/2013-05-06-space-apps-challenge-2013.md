---
title: Space Apps Challenge 2013
published: 2013-05-06 18:00:00 +0000
tags: space-apps-challenge, predictthesky
---

A few weekends ago was the second [NASA Space Apps Challenge][], a hack day centred
around building stuff related to space and worldwide collaboration. The
[last one was fantastic][last] and this one also did not disappoint. This time 
around, we set around to continue working on Predict the Sky, but more of that in a 
bit.

For me, it worked out as a nice breather before the mad rush of [finishing off my
project][dissertation] (even though I did spend some time reviewing some code and
adjusting a few things).

But, more interesting was seeing what other people were coming up with. As an
offshoot of [Growers Nation][] (er, pun not intended) we had an open hardware soil
analyser, entitled "[MudPi][]", which is able to collect humidity, temperature,
dew point & moisture and is designed to be placed in the soil somewhere. They were
commended for being quite close to market. I'll be interested to see what comes
next out of it.

Next, was a collection of projects from mostly [Plymouth University][] students
entitled [ArduHack][] that was focused around the [ArduSat][] platform. This is an
[Arduino][] based [CubeSat][], which itself is a project with the aim to reduce the
cost of getting satellites into space &mdash; to the point where groups of people,
researchers (as in, not space ones) can do. Anyway, half of the team was focused
upon attaching an earth orientated camera to the ArduSat, so that people would be
able to photograph themselves from space; the key bit here was being able to
photography themselves &mdash; people could essentially operate their own spy
satellite for a moment in time.

The other half of the ArduSat project was about bringing some of the sensors "back
down to earth". Using a combination of a [Magician Robot Kit][], an Arduino, 
[Raspberry Pi][] and a [TI SensorTag Development Kit][]. The key bit is the last one,
it includes an IR temperature sensor, a gyroscope, accelerometer, magnetometer,
pressure sensor and a humidity sensor all of which are able to communicate over the
[Bluetooth Low Energy][] standard. From here, they used the Raspberry Pi to
communicate with the SensorTag, to then control the Arduino which would drive the
robot around.

Finally, the team behind [WebRover1][] where looking at expanding what a set of
[Lego Mindstorms][] based robots could do for outreach &mdash; getting young people
interested in robotics and it's related [STEM][] subjects. They ended up with new
control code and an easy to use front end which would work with most browsers
(aimed a touch devices). Their project page gives a better explanation of the user
interface design process.

There were several other interesting things by other groups there, too. And, the last 
two, [ArduHack][] and [WebRover1][] are up for global judging.

## A Continuation of Predict the Sky

A few weeks before the event, I'd emailed around asking to see if any of the old
team were interested in spending the weeknd continuing on with Predict the Sky. My
hope was to catch up with the work which was done at the Met Office's Weather for
Fun event last year (which I'd missed) and for us to work out where we'd take the
project. Personally, I wanted a documented API that we could wave around at people
and then from there work on the mobile applications and so forth that we had worked
on at the first Space Apps Challenge.

And actually; that's exactly what we did. [Emma][] was around all weekend, [Sophie][]
was with the [WebRover1][] team (but we grabbed her on a few bits and pieces) and we
were joined by a few more people.

In the end, we ended up assembling [predictthesky.org][pts], which will contain a
description of what the project is all about, the people involved, the API
documentation (there's some examples at the moment, they need actually implementing)
and eventually some cool projects that are using it.

We also looked at the way we were going about calculations and the data sources for
certain objects. We'll be using [PyEphem][] for much of it and relying on [Space Track][]
for the object references (a project run under contract to the US Department of
Defence). A few other data sources will be used for other objects, too.

The whole API will eventually be implemented using [Flask][] and you can find the
code (and source for the GitHub Pages based site) under the [Predict the Sky 
Organisation][].

My next steps after I finish University (rather soon, now) is to start on the code
side, and also build out the documentation &mdash; especially for others to
contribute who are new to the project.

In the mean time, if you're interested, [shout at me](/about) and I'll make sure
something is done about it.

But overall, another great event, one of hopefully many more to come.

[NASA Space Apps Challenge]: http://spaceappschallenge.org/
[last]: /posts/nasa-space-apps-challenge-predict-the-sky.html
[dissertation]: /posts/final-year-project-over.html
[Growers Nation]: http://www.growers-nation.org/
[MudPi]: http://spaceappschallenge.org/project/mudpi
[Plymouth University]: http://plymouth.ac.uk/
[ArduHack]: http://spaceappschallenge.org/project/arduhack/
[ArduSat]: http://www.kickstarter.com/projects/575960623/ardusat-your-arduino-experiment-in-space
[Arduino]: http://arduino.cc/
[CubeSat]: http://www.cubesat.org/
[Magician Robot Kit]: https://www.sparkfun.com/products/10825
[Raspberry Pi]: http://www.raspberrypi.org/
[TI SensorTag Development Kit]: http://www.ti.com/tool/cc2541dk-sensor
[Bluetooth Low Energy]: http://en.wikipedia.org/wiki/Bluetooth_low_energy
[WebRover1]: http://spaceappschallenge.org/project/webrover1/
[Lego Mindstorms]: http://mindstorms.lego.com/
[STEM]: http://en.wikipedia.org/wiki/STEM_fields
[Emma]: https://twitter.com/ehibling
[Sophie]: http://www.sophiedennis.co.uk/
[pts]: http://predictthesky.org/
[PyEphem]: http://rhodesmill.org/pyephem/
[Space Track]: https://www.space-track.org/
[Flask]: http://flask.pocoo.org/
[Predict the Sky Organisation]: https://github.com/PredictTheSky

