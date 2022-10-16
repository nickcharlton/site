---
title: "Review: Hacking and Securing iOS Applications by Jonathan Zdziarski"
tags: review, book, ios, hacking, security
---

I started this just after the [Path fiasco](http://nickcharlton.net/post/mobile-security). It seemed timely to brush up on my security knowledge, especially for iOS intricacies, recommended practices and understanding obvious flaws. At the same time, O'Reilly had published ["Hacking and Securing iOS Applications" by Jonathan Zdziarski](http://shop.oreilly.com/product/0636920023234.do), so I got a copy. This book provides exactly what I wanted; it's a great next-step if you've been developing for iOS or the Mac for a while. Fortunately it assumes that, which allows the book to quickly jump into examples and solutions. 

After debunking some common myths, the book delves into pushing code onto a jailbroken device. It was quite an eye opener to see how simple it was (this isn't something I've done since back on iPhone OS 1.3.3, or so.) If you can compile something using gcc, you can just about as easily (and quickly) push something onto a device. 

Related to the Path fiasco, the next fuller example (in Chapter 2) is about pushing the Address Book over the network. I found that quite amusing.

The book then descends into exploiting the filesystem, and other common attack vectors. This is followed by sections on manipulating the Objective-C runtime and examples in applications which are the time of writing claimed to be "secure", but suffered from simple to discover flaws.

The second half of the book delves into advice on writing secure applications. Its "now you know what you can do, here's how to engineer around it" style works fantastically and provides the most value - especially if you're building something which is security conscious. Notable here was the chapter on encryption. It covered implementing SSL and flaws relating to it, as well as delving into using public-key encryption along with SSL when passing data around.

After this, the book delves into ways to obfuscate methods and protect the data the application is working with. For example, providing traps which when executed would erase any useful encryption keys, or phone home (passing logs and/or GPS coordinates) to help mitigate any knock-on effects of a breached application. Some of these security holes are due to the reflective nature of Objective-C, which allows you to modify the runtime as it is executing - catching tampering attempts, or placing honey traps for attackers can be used as another line of defence.

But, more importatly, the book aims to bring across a fundamental of security and penetration testing: You need to think and act like an attacker to see potential flaws and attacks. For this it is organised well, and because of that, it's a great position to leap off from.

_O'Reilly provided a copy of the book for to review for free, as part of their Bloggers Programme._

