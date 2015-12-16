---
title: Converting a sparseimage to a dmg
published: 2008-11-01 07:00:00 +0000
tags: 
---

The process of converting from one type of disk image to another is usually handled by the software created by it. However on the other hand, if you don't have enough HD space when say, running a full Carbon Copy Cloner backup of your machine, you may elect to instead just produce an uncompressed sparseimage.

The process for doing this is quite easy and logical, but not so easy to remember.

	hdiutil convert -format UDZO Source.sparseimage -o Output.dmg

The process will of course take quite a while, but you will be provided with a simple ".." style progress bar.

`hdutil` is also SMP aware, so it can use more than one CPU. This not only faster, but will also hammer your machine. With this reason in mind, I'm not sure if it would be wise to run it with a low process number, if you are planning on doing a lot at the same time, maybe this would be a good idea.

