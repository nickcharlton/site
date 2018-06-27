---
title: Bats, Hacks &amp; Fieldwork
published: 2012-05-29 23:13:06 +0000
tags: field-studies-council, hackday, bats, electronics, ios
---

Two weekends ago, I was in Slapton at the [Field Studies Council](http://field-studies-council.org/) for their first hack day. It aimed to bring together both people in education and those in technology and see what could be done when you bashed their two heads together. And it was bloody good.

Set in the picturesque Devon countryside, a bunch of us turned up not quite knowing what to expect. For most, it'd been quite a while since Geography lessions in school, let alone any fieldwork.

The hackday had been organised by [Harriet White](https://twitter.com/FolkPrincess) of the FSC, [Ant Miller](http://reithian.blogspot.co.uk/) of BBC R&D, and [John Bevan](http://about.me/johnbevan) of Mozilla. But we also had people from elsewhere in the BBC, a few associated with [Rewired State](http://rewiredstate.org/), FSC tutors on hand and designers and developers of various afflictions. We were also lucky to have a few people from the [Bristol Hackspace](http://bristol.hackspace.org.uk/), too.

<figure>
<img src="https://nickcharlton.net/resources/bats_hacks_fieldwork/pub.jpg" width="500" alt="The Tower — The Lovely Local Pub">
<figcaption>The Tower — The Lovely Local Pub.</figcaption>
</figure>

### Bat Detection

<figure>
<img src="https://nickcharlton.net/resources/bats_hacks_fieldwork/bat_guide.jpg" width="500" alt="The FSC's Guide to British Bats">
<figcaption>The FSC's Guide to British Bats.</figcaption>
</figure>

[Mike](http://mike.saunby.net/) and I worked on a low-cost bat detector. Mike had picked up an off-the-shelf bat detector and had been experimenting with outputting typical British bat tones (in the 40kHz to 110Khz range) using a multitude of different devices. In the end, he'd found that it was possible with expensive external sound cards and really cheap internal sound cards (we concluded that manufacturers are unlikely to ensure output is kept to a sensible range at the low end, but unlike the expensive stuff it certainly wouldn't be optimised for being used like it.)

This allowed us to simulate bat calls indoors, at any time. For us, this was vital. But has the additional effect of being mightily useful in the classroom. On a weekend of fieldwork, there would not be much chance for evenings spent hunting around for bats; a simulator could provide a demonstration of what it'll be like using bat detectors and what you would be likely to discover.

After experimenting with a few different bat detectors, we talked about what we could do to make bat finding more accessible. In the morning of the first day, [David Rogers](http://daviderogers.blogspot.co.uk/) of the [Priory School](http://prioryschool.wordpress.com/) in Portsmouth had talked about student devices and what he (and other teachers) had been doing to use them to aid learning. Whilst the <abbr title="Bring Your Own Device">BYOD</abbr> model seems slightly problematic for our case<sup><a href="#footnote_mobile_1" id="identifier_byod_1" class="footnote-link">1</a></sup>, a universal bit of hardware seemed a good place to start.

Off the shelf bat detectors use frequency shifting to take the bat's ultrasonic clicks and squeaks and turn it into human audible frequencies. In the UK, bats are typically somewhere around 45Khz. (Human hearing is somewhere between 20Hz-20Khz.) Fortunately, doing this is quite typical (its how transistor radios work) and relatively cheap to do. So, with this in mind, we came up with the idea of a [Square](https://squareup.com/square) like dongle which is inserted into the audio input of a mobile device. The device can then "listen" in to the audio signal and provide some sort of output.

Mike spent the rest weekend working on the circuit, and quite quickly got something working. He then iterated over it to attempt to reduce the amount of components, and try different microphones to see which was best. [I'm sure he'll blog about it soon](http://mike.saunby.net/).

In the mean time, I looked into how we could analyse and present the audio data as it came in, and what the audio range of the iPhone<sup><a href="#footnote_platforms_2" id="identifier_platforms_2" class="footnote-link">2</a></sup> was like. I didn't go much further with looking at the audio range, other than concluding that it was at least slightly outside of standard Human hearing range, but seemingly not up to ultrasonic.

I quickly discovered that audio programming is hard. Or at least, low-level audio programming is. Exploring the lower-level [Core Audio APIs](https://developer.apple.com/library/ios/#documentation/MusicAudio/Conceptual/CoreAudioOverview/Introduction/Introduction.html) was a little beyond hacking at a weekend. I did however recall reading about [Novacaine](http://alexbw.github.com/novocaine/) and a few other audio recording projects which kickstarted pulling in audio data. 

I was quite surprised to find that graphing the data was also not easy. With libraries for most things, you assume it'll be easy to put together a time-series graph of live data. Whilst the likes of [Core Plot](https://code.google.com/p/core-plot/) exist, it's not as elegant as it could be. Subsequently I've spent last weekend working on something to solve it. It's common for bat detectors to use frequency-histograms to show 'loud' points in the past over various frequencies at once, as this helps with detection, too. So I also need to work out how to do that. Graphing additionally comes with the advantage of being far more accessible than an audio output. We're already shifting sounds that we, as humans are unable to hear, so why do we limit it to outputting just human audible sound?

Handily, Novacaine is extracted from a few audio analysis projects which in the end I used to demonstrate what we'd found. On the concluding part on the Sunday, the attendants, organisers and judges came around to each lab to see what we'd done. After Mike had run through the basics of bat detection, and the circuit that he'd put together, we demonstrated what could be done using an iPad and [oScope](http://itunes.apple.com/us/app/oscope/id344345859?mt=8). You could clearly see the bat calls on the oscilloscope display, as played through a cheap netbook and the speakers in the room.

It also turned to demonstrate the phenomena of [presbycusis](http://en.wikipedia.org/wiki/Presbycusis) or age-related hearing loss, as the room speakers spread across the audial-range of the bat recordings more than on the netbook did on its own. People under the age of ~35 were unable to hear this noise, but those below could. (It's like a very high-pitched, uncomfortable drone.) We also discovered that modern (especially cheap) digital electronics are remarkably noisy in the ultrasonic range. Passing one of the bat detectors over certain devices in various different ranges lead to a lot of background noise.

### Winning an Award

We were in Lab 1 and went first. After we'd done our demonstration, we went through the other labs to see what had been done. Everyone did something fantastic. From 3D printed representations of beach profiles, to Arduino powered data logging and applications for collecting data in the field, to tools for anaylising that data back in the classroom. Everyone attempted to solve — with a sane use of technology — the problems that the team have at the FSC.

On the blog, [Ant has written up about all of the projects and the winners](http://fschackday.wordpress.com/2012/05/22/fsc-hack-winners/). Which you should go and read.

Done that? Good. Well, there were four awards. And we won one of them!

We won the "People's Choice Award", awarded by putting stones into tubs after we'd all looked at the different projects. It was extremely satisfying to gain the approval of all of the other people there. It was fantastic to see so many people interested in what we had been doing.

### Documeting it All

Before and during the weekend we had [Rowan Stanfield](http://rowstar.blogspot.co.uk/) and others documenting the event. I'm pretty sure I haven't seen it done to this much detail before. Looking back it was quite a marvellous idea. The whole weekend is laid out for us to look back onto, as well as for others to see what was done. It provides a fantastic documented legacy of the whole event.

You can see all of this on the [Fieldwork Hackday](http://fschackday.wordpress.com/) site.

### Result Showcase Event

On Wednesday there is a [wrap up/project show off event up in London](http://lanyrd.com/2012/fschackresults/) at the Mozilla Space. I'll be there presenting the bat stuff (with hardware, too!)

I understand it's going to be streamed — as well as showing off the video that was produced of the event. I'll write up something else after the event, probably with more pictures.

---
<ol class="footnotes">
    <li id="footnote_byod_1">It's hard plan out where you dedicate resources to an almost unlimited amount of possible devices. Especially on a project like this. But, more importantly, it's unfair to over emphasise finances where we want people learning.<a href="#identifier_byod_1">↩</a></li>
    <li id="footnote_platforms_2">Given I've spent the last year doing iOS development it was the right thing to start on. But, there's absolutely no reason why it wouldn't work elsewhere too.<a href="#identifier_platforms_1">↩</a></li>
</ol>

