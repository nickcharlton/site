---
title: Installing Ubuntu 9.04 on an SD card
tags: ubuntu, sd-card
---

**Note: This article is quite old. It probably doesn't apply anymore. Your
mileage may vary.**

<p>To to this I used a <a href="https://www.amazon.co.uk/gp/product/B000WQKOQM?ie=UTF8&amp;tag=nisbl-21&amp;linkCode=as2&amp;camp=1634&amp;creative=19450&amp;creativeASIN=B000WQKOQM">SanDisk 4GB SDHC card which can be bought for around £6/$9</a>. Better performance could be gained from using a faster card. However, for the most part this card is quite acceptable.</p>

<p><em>Note: Solid state memory (such as SD cards) generally has a limited amount of writes that can be possibly made to it. This means that the card used will not last forever.</em></p>

<h2>Step 1</h2>

<p>The first step is to prepare the tools you need and boot from the installation media.</p>

<ul>
	<li>Ubuntu 9.04 Desktop ISO image</li>
	<li>A CD or thumb drive (to install the image from)</li>
	<li>SanDisk 4GB SDHC Card</li>
	<li>A machine to try it on</li>
</ul>

<h2>Step 2</h2>

<p>I chose to first boot into the live environment and run the installer from there. Whilst I have had bad experiences using CD drives for such a procedure, booting off a thumb drive is quite acceptable.</p>

<p>Next, start the install.</p>

<h2>Step 3</h2>

<p>When you reach the partitioning stage you will need to select the SD card, rather than the hard drive. On my system (an HP (2133) Mini) this appeared as "/dev/sdc" as a SCSI device.</p>

<p>The naming of the device will vary per system, so could show up as hdc (if it is on an IDE controller) or in another manner.</p>

<h2>Finally</h2>

<p>Once that is finished all that is required is to boot the system. You could set this in the bios to boot first, in which case it'd boot if an external drive is inserted first, or pick at boot time.</p>

<h2>Some Notes</h2>

<ul>
	<li>Overall, Ubuntu 9.04 used 2GB (or 50%) of my 2GB drive.</li>
	<li>Issues: When suspending I noticed that it would not be able to mount the disk, and thus fail.</li>
</ul>

