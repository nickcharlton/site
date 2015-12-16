---
title: Brussels &amp; FOSDEM 2012
published: 2012-02-12 21:44:16 +0000
tags: brussels, belgium, fosdem, conference
---

Last weekend, I was in Brussels for [FOSDEM](http://fosdem.org/2012/). It was an excellent weekend. I didn't go too that many sessions at FOSDEM, but the ones I did go to were pretty good and have pushed me into finding out a few more things in detail.

The first session I went to was titled ["Why Java for Linux applications?"](http://fosdem.org/2012/schedule/event/javalinuxapps). It was interesting to see someone's approach to implementing something that needed to be cross-platform, but I find both the development environment and the eventual product of [Swing](http://en.wikipedia.org/wiki/Swing_(Java)) hard to take as a recommendation. The next session was ["Debian packaging for beginners"](http://fosdem.org/2012/schedule/event/debian_packaging). I've done some repackaging before, but nothing completely from scratch. It was interesting to see the process done, it's not as complex as it first makes out. After these, I headed over to the GNUstep Devroom. 

Since spending a large amount of time developing for iOS, and some for the Mac, I'm obviously heavily invested in Objective-C and Cocoa. The [talk on the newer features of Obj-C](http://fosdem.org/2012/schedule/event/new_objc_features), by [David Chisnall](http://www.cs.swan.ac.uk/~csdavec/) was especially interesting. Support for the likes of Automatic Reference Counting and blocks is far more comprehensive than I expected, and in some cases far better than Apple's own implentation. I'll be interested to see how the [Étoilé](http://etoileos.com/) project and others progress.

On the other hand, the final talk of the day, [QuantumSTEP](http://fosdem.org/2012/schedule/event/quantumstep_future) was less impressive. It provides an implementation of Objective-C and Cocoa for the [GTA05 Open Source Phone platform](http://www.quantum-step.com/). It seemed to be a little too much about slowly chasing up iOS, which itself is moving rather fast. It was interesting, though. 

On the Sunday, I primarily spent time in the Virtualisation & Cloud Devroom. I had previously heard about [oVirt](http://www.ovirt.org/), but without an official release hadn't looked too deeply into it. The introduction talk, ["Virtualization Management the oVirt way"](http://fosdem.org/2012/schedule/event/ovirt_intro) and the subsequent talks outlined the architecture that was being implemented.

oVirt is intended to be an open source version of [VMware's vSphere](http://www.vmware.com/products/vsphere/mid-size-and-enterprise-business/overview.html) product, but using [KVM](http://en.wikipedia.org/wiki/Kernel-based_Virtual_Machine). The goal here is to provide a managed environment for running VMs, either for servers or "virtual desktops" for end users. This arrangement provides failover and general management on the server, rather than at the application level - something more common with traditional, non-web application infrastructure. 

Unfortunately, it seemed a brittle solution to the problem. I'm not a fan of projects that are made up of many complex interconnecting parts to form a whole. At least not when they depend on a core central component. There also seemed to be a little confusion in the Q&A about what would happen if you upgraded the frontend (nothing bad, as it happens), which was a little disconcerting. But, at the time, it hadn't yet been released (this happened on the 9th Feb). I shall likely be giving it ago at some point. 

Other than sessions themselves, I met up with [Bob](https://twitter.com/bob_moss) on the Friday for an eventful, but good evening at the [FOSDEM Beer Event](http://fosdem.org/2012/beerevent). There, I also met Kostas Georgiou & Elaine McLeod from [OpenGamma](http://opengamma.com/), who are working on an open platform for the financial services industry. Interesting stuff.

On Sunday afternoon, I met up with [Goedele](http://www.flickr.com/photos/tesfruitsmonjus/), which was good fun. After grabbing some lunch, we went to this odd bar which serves beer in skulls. The music was good, too. 

Belgium was exceptionally cold for much of the time. When Ben and I arrived, it'd already been snowing for quite a while. I gather on the Friday night it got down to somewhere around -12°.

Belgium is a lovely country, which topped off an excellent weekend.

