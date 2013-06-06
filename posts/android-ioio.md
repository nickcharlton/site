---
title: Experiments with Android, a IOIO board and Heart Rate Monitoring
published: 2013-06-06T02:02:00Z
tags: projects, android, ioio, heart-rate-monitor
---

A few weeks back now, I worked on a project for [iDAT][]. I came in at the end to
fix a few bugs on a Android/hardware integration project. The idea was to use an
Android phone, along with a [IOIO][] board and a [Polar heart rate monitor breakout
board][hmri] to collect data on a person's movements, heart rate (and a few other 
things).

This was split into two distinct sections; the first was the hardware itself and
secondly the software which would poll data from the IOIO board and do something to
visualise it.

For the hardware, I started off first trying to get some data from the HMRI (the
shorter name of the breakout board) using an Arduino. This worked quite quickly.
The board uses I&sup2;C to communicate and so this is only a few pins. Whilst 
[Dan Julio][] provides some example code for the Arduino, this was a bit old and so
I needed to update this. You can find the updated code in my GitHub project,
[hmri_arduino][]. It should work fine with Arduino 1.0 and greater.

To interface the HMRI with the IOIO board, the process was much the same as the
Arudino, but I needed to provide two 4.7k&Omega; pull up resistors to get a signal 
(the Arduino provides these for you). I also needed to desolder the SJ1 contacts and
solder the OP0 contacts for an I&sup2;C connection, a section from the manual is
listed below.

<figure>
  <img src="/resources/images/hmri_schematic.png" alt="I&sup2;C Schematic from the manual">
  <figcaption>Figure 1: I&sup2;C Schematic from the manual</figcaption>
</figure>

After this, I needed to interface the HMRI, through the IOIO board on the Android
device. The IOIO project provides a library to do this &mdash; the interface is
Arduino inspired &mdash; and once you get the correct version, it's quite easy to
get working.

I was using a Samsung Galaxy SII (with a slightly older version of Android) and the
older style IOIO board. I matched up the board type with the current release as
listed on the [IOIO downloads page][]. This ended up stumbling me for quite a while;
the board refuses to connect without precisely the right firmware/library 
combination.

For the implementation itself, I used a [singleton][][^antipattern] which is 
started up with the main activity and is then shutdown on completion. The idea behind 
this was to create a connection to the hardware and keep one thread which would 
handleit (the singleton starts a thread for interacting with the  hardware, and then 
provides a thread-safe way in which to interface with it). Sadly, this didn't quite 
work with the way Android is designed and so doesn't quite work how I had expected. 
Instead, the hardware connection is started and stopped when the main activity 
run-loop is either started or stopped. Due to the way Android implements it's 
run-loop this is all that is possible (coming from predominantly iOS, this such an 
odd implementation and quite annoying).

I never resolved the issue before shipping; as far as I understand, it's impossible 
to fully resolve it because of Android's stupid implementation.

And finally, the code for [the whole project is up on GitHub][project] (which should
give you the best way to see it in action).

[^antipattern]: Many consider the Singleton to be a programming anti-pattern, but
    I disagree for situations such as this. Yes, it does introduce global scope,
    but when you're accessing hardware, or a data model (where I've used singletons
    before) it works quite well. You only want to instantiate it once, anyway. In
    the case of hardware it's preferable to keep the same connection open.

[iDAT]: http://www.i-dat.org
[IOIO]: https://github.com/ytai/ioio/wiki
[hmri]: https://www.sparkfun.com/products/8661
[Dan Julio]: http://danjuliodesigns.com/sparkfun/hrmi.html
[project]: https://github.com/i-DAT/Bio-OS-Android
[hmri_arduino]: https://github.com/nickcharlton/hmri_arduino
[IOIO downloads page]: https://github.com/ytai/ioio/wiki/Downloads
[singleton]: http://en.wikipedia.org/wiki/Singleton_pattern

