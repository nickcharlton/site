---
title: ORGCon 2012
published: 2012-03-29T22:56:22Z
tags: conference, open-rights-group, privacy, data, copyright
---

On Saturday, I was at the [Open Rights Group](http://www.openrightsgroup.org/) Conference at the University of Westminster in London. It was a very good day, full of interesting talks from the likes of Cory Doctorow, Wendy Seltzer and Laurance Lessig. It was the first time I've seen these talk in person (Lessig was notably impressive - especially with his slides.) Below are some of the notes I made.

### Cory Doctorow: The Coming War on General Purpose Computing

This was about the progression towards specific computers - not ones which can crunch any numbers that you throw at it, but tailored and locked down to a specific purpose. 

* Original ”early” DRM -> Easy to break. Broken because it was more convenient with it removed.
* The early information age was very much a ”charge for all the things” charging module. Skipping, pausing, etc.
* DRM is exponentially problematic, one use opens up many more problems and as you solve those the problems just get bigger. 
* Complete failure of the UN’s (WIPO) copyright laws. 
	- they posed unrealistic demands upon reality. 
	- it's a good example of a worldwide treaty which solves a  of the wrong problems. 
* Law makers represent populations of people, not subject areas. They use heuristics to balance good rules for the population. 
* But these heuristics utterly fail for technology. 
* General Purpose Computing is much like the wheel is to the car. 
* As control is aimed at General Purpose Computing, appliances look like a solution. 
* Unfortunately, this opens up more issues: SOPA, Human Rights, etc.
* Copyright however is usually considered less economically important (certainly in comparison to food, water, etc), even though computers now essentially make up everything around us. 
* Every big industry will turn to the easy solution of locking down General Purpose Computing. 
* Thus, the fight will only get harder. 

This talk was an updated version of a previous one, and also [an article on BoingBoing](http://boingboing.net/2012/01/10/lockdown.html). 

### Wendy Seltzer: Organising for the Open Net

* With SOPA/PIPA, representatives finally saw the power of the Internet.
* There is a long history of stupid, naïve attempts at legislation in the States ([HEOA](http://en.wikipedia.org/wiki/Higher_Education_Opportunity_Act#2008_reauthorization), [COICA](http://en.wikipedia.org/wiki/Combating_Online_Infringement_and_Counterfeits_Act).)
* You cannot control the Internet without fundamentally breaking it.
	- the Internet would not have grown to be what it is with significant control. 
* And, how can it be right that one Government Department can prop up a dying business model?
	- whilst one part of the US Government was praising the freedom of speech aspect, others were going in the opposite direction.
* The power of the hivemind for real world events cannot be understated. Even the effect that changing a Twitter avatar has is greater than one would expect. (Even if it does appear to be "[slactivism](http://en.wikipedia.org/wiki/Slacktivism)")
* The "white blood cell"/vaccine metaphor fits quite well. But, can following such a model actually make us more resilient against future issues?
* But an immune system can also kill itself if it overreacts. We (as the internet), have to be careful to not cry wolf at the next piece of legislation to rear its head. 
* Motivation to keep fighting can and will come from the very specific niche interest that makes the general purpose Internet amazing. 

### Panel: Is all this data doing us any good?

This session was a panel, with [Chris Taggart](https://twitter.com/#!/CountCulture) of [OpenCorporates](http://OpenCorporates.com/), [Rufus Pollock](http://rufuspollock.org/) (of Open Knowledge Foundation) and [Heather Brooke](http://heatherbrooke.org/) (who worked on uncovering the MP's expenses scandal). It was split into questions, but some notes ended up merged into others. 

#### Who are ”we” empowering?

* Only about 1% of all Government data (in the UK) is being opened up. 
* That is mostly because it is sold, and a business model has been built around it. 
* Stops Innovation. "If your business model doesn't match, you can't play."
* Closed data is growing exponentially, far faster than that which is being open.
* We're empowering everyone. But, the small guy has far more power even with smaller resources.
* The American journalism model relies upon public records. In the UK, we don't have this. Unfortunately, this leads to a patronage network - making it harder for new people to get in.

#### Value

* Governments may very well agree with opening up data, but it is expensive (it needs to be organised, packaged, etc.)
* Government need to understand the bigger social value other than the direct business profit.
* However; data without tools isn't useful.
	- tools, analytics, etc is a resource problem.
* "Pirate" Data Sets are good and bad.
	- The MPs expenses leak was good - it raised public awareness of an ongoing issue.
	- The Wikileaks "cablegate" wasn't good - it hurt government's opinions on transparency (not everything is appropriate open.)
* Journalists need tools and education to be able to utilise data for the "common man". Just opening up stuff isn't useful.

#### Opening Up Data

* It's a politcal, rather than legal issue.
	- even though it might well be against usage terms and conditions, organisations are often happy to ignore them to see people doing good things with it.
* The ease of getting data opened is somewhat because someone isn't fighting the other way (unlike copyright, for example.)
* Do it, appologise later. "Generally" not much has happened to people doing precisely that.
* A good way forward would be "open by default" - no more Crown Copyright, for example.
* But, people need to ask for data that they wish to use - organisations may just assume people aren't interested otherwise.
* And, uncovering something like corruption because of open data wouldn't hurt at all.

### Ross Anderson: How Secure is the Anonymisation of Open Data?

This session was given by [Ross Anderson, a Security Professor at Cambridge Computer Lab](http://www.cl.cam.ac.uk/~rja14/). It mostly focused upon medical data, and the information than can be inferred from disparate data sets.

* Back in 1979, it was shown that you can find more data than anyone had previously expected in US Census Data.
* In the '90's, it was shown that a State Senator could be identified through health data.
* The same happened in the UK with NHS data.
* Generally, if you know enough information about a place (e.g. Cambridge Computer Lab.) you can easily glean a lot from publicly available data (for example, there is only one female professor, and the University publish average salary statistics.)
* It is very hard to stop data leakage through inference unless you know all of the cases where it can be "attacked".
* The more data that is opened up (inc. social network data), the more patterns that can be seen.

### Mozilla: Do Not Track

* Aims to give users a universal, simple opt-out from advertising based data collection.
* It is being standardised, by consensus by the W3C (from a mix of privacy advocates, advertisers and governments.)
* Implemented as an HTTP Header, and an accompanying JSON status file.
* In general, the policies define the levels of sharing between first and third parties on a given website (e.g.: a Twitter "Tweet" button is a third party to the New York Time's site, until you click on it.)
* It also defines "outsource" providers for analytics and CDNs.

My initial thought with this was about it's "opt-out" nature and requirement that organisations implement it at their end. The well-behaving organisations are likely happy to be involved and implement it - but they're probably already not doing crappy things with data collected from our browsing sessions.

You can read more about [Mozilla's Do Not Track Project here](http://dnt.mozilla.org/).

### The Upcoming Data Protection Act Changes

* The original, "business friendly" [Data Protection Act](http://en.wikipedia.org/wiki/Data_Protection_Act_1998) will be (in about four years) replaced.
* In general, this will balance out the laws throughout the EU.
* Industry should see less red-tape.
* Notably however, instead of two sets of data being considered seperate (where one could be identified from the merging of the two), this would no longer be allowed. [See "How Secure is the Anonymisation of Open Data?, above.]
* What defines "personal data" is being redefined (e.g.: IP addresses, cookies, etc.). Some of this is still undefined.
* It is also possible that there will be a clause requiring individuals to request data from companies that is stored about them.
* And it is also possible that there will be a clause requiring companies to comply with user's requests to remove data stored about them (this may cause issues for search engines, social networks, etc.)

### Laurence Lessig: Recognizing The Fight We're In

[Lessig](http://www.lessig.org/) is a fantastic speaker. This talk was an outcry to release how important the fight for which the ORG stands for is. It spreads from the model of spectrum allocation for managing radio standards to corruption in modern politics.

* Spectrum allocation (and property) only works on big, wide broadcasts, not the small scale usage we generally see now (e.g.: wifi, bluetooth, etc.)
* Why can't the TCP/IP model work?
	- defined as scalable usage with users, rather than applying scarcity.
* It stays as property because of lobbyist.
	- We need to rememeber to askt he question: "Who makes money from this?".
* Poor broadbad, copyright extensions & SOPA insanity is all driven by greed.
* Fundamental copyright is necessary. However, it needs to benefit the creators & authors - not publishers.
* Locking up academic information in exclusivity is an ethical problem.
	- How can it be right that publically funded research makes money for private publishing organisations?
* The state of US politics is a kind of corruption - relative to the baseline on which it was founded.
* Most people do not vote because they have no belief in the system.
	- it is thought that corporate interests rule the way and that voting alone is pointless.
* The growth of citizen politics is leading to an international anti-corruption movement. This is a fantastic thing.

You can watch [the video of Lessig's talk here](https://vimeo.com/39188615).

