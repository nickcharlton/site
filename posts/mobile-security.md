---
title: Mobile Security: I Don't Even Know Where to Begin
published: 2012-02-13T20:01:09Z
tags: security, mobile, ios
---

With the [recent Path debacle](http://mclov.in/2012/02/08/path-uploads-your-entire-address-book-to-their-servers.html), the security and privacy practices of various mobile application developers has come to light. Generally, this has focused around the use of Address Book data; here, developers are balancing violating individual privacy with easier connections - the metric of importance for such apps. On its own, this is fine — providing you have the user’s permission — the issue is in how developers are going about implementing it.

Security is a numbers game. Nothing is or will ever be perfectly secure<sup><a href="#footnote_mobile_1" id="identifier_mobile_1" class="footnote-link">1</a></sup>, but the whole notion of attempting to protect users seems to have been entirely ignored. In most cases (Path, for example) this is just blind ignorance, but [others seem to be actively avoiding such simple things as hashing](http://mybroadband.co.za/news/cellular/43301-zing-mobile-messaging-app-all-the-details.html).

I'm not sure which is worse. Is it worse that developers simply did not consider encrypting the data they were passing around, or another developer actively decided against it? At least if users know that their data is not being encrypted along the wire, and is being stored in plain text they can make a decision about whether or not to use it<sup><a href="#footnote_mobile_2" id="identifier_mobile_2" class="footnote-link">2</a></sup>. I suspect the bigger issue is education. The open nature of the Web is a fantastic thing and to some extent this is transferring to mobile development, too. 

But this means that developers do not have a well rounded conceptial understanding of what they are doing. Developers like Matt Gemmell shouldn't have to write articles like: "[Hashing for privacy in social apps](http://mattgemmell.com/2012/02/11/hashing-for-privacy-in-social-apps/)" and [receive responses from other developers](http://twitter.com/mattgemmell/status/169039433226649600).

On iOS, the Address Book API calls have almost entirely been pulled over from the Mac. Only the picker tool is Cocoa, the rest is Core Foundation (C). I suspect the lack of user permissions is because of this, rather than any malicious intent. [Regardless, it's against the developer agreement](https://developer.apple.com/appstore/guidelines.html).

I certainly don't think that a CS degree should be a prerequisite  for building any software; but somewhere we, as developers need to build up interest into. Just throwing in a little bit of hashing and salting at the end of a project cannot be a valid security standpoint to take for software that is used by a wide variety of users.

<ol class="footnotes">
    <li id="footnote_mobile_1">In iOS's case, whilst the filesystem is encrypted, it's still like keeping your house keys under your doormat. You cannot unlock the filesystem without also shipping the keys with the device. <a href="#identifier_mobile_1">↩</a></li>
    <li id="footnote_mobile_2">But I don't think this is a good excuse. As app developers it is our, as much as the platform providers’, responsibility to protect our users. <a href="#identifier_mobile_2">↩</a></li>
</ol>

