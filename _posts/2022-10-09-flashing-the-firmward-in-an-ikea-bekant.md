---
title: "Flashing the firmware in an IKEA BEKANT to add position memory"
published: 2022-10-09 21-27-21 +01:00
tags: project ikea desk
---

As I started to work from home at the beginning of the pandemic, I got an IKEA
BEKANT sit/stand desk. It's been great for my posture and managing the fatigue
of being at a desk for a long time every day. My main frustration has always
been that it doesn't have a memory — you can only hold the up or down buttons
to move it and so trying to get it to the same position is annoying enough to
avoid doing it.

Fortunately, someone [reverse engineered the firmware and published a
replacement which can be flashed on the existing hardware][1].

The BEKANT controller is a [PIC microcontroller][3], so you'll need a PICkit
programmer to flash it. [I got one of these][2], which was about £20 a few
months before doing it. You'll also need the Microchip environment, [MPLAB
X][4].

## Preparing the controller

First, I set the desk to the right sitting height. If it went wrong, it was
much better to have it lower. You're going to want to do something like:

1. Power down the desk,
2. Unscrew the controller from underneath,
3. Open up the back

{% picture url: "resources/images/ikea-bekant-controller.jpeg",
           alt: "Photograph showing the start of opening up the controller" %}
  IKEA BEKANT Controller: Opening
{% endpicture %}

It's quite difficult to open the back. It's glued down and made me have some
grumpy thoughts about right to repair. I first tried to use a knife to get some
space, but this didn't work too well. From seeing photographs of others doing
this, I realised there was space unused in the case where I should be safe to
drill into. I drilled three holes into the corner and then used some pliers and
snips to break it open.

You'll see something that looks like this.

{% picture url: "resources/images/ikea-bekant-controller-back-cover-removed.jpeg"
           alt: "Photograph of the back cover removed" %}
  IKEA BEKANT Controller: Back Cover Removed
{% endpicture %}

## Configuring MPLAB

* Open the MPLAB IPE,
* Configure for the PICkit 3.5
  * Settings → Advanced Mode (the default password is `microchip`),
  * Set the device to `PIC16LF1938` and click "Apply",
  * Under "Power", select "Power target circuit from PICkit3" and set the
    voltage level to "3.25",
  * Under "Production", select "Allow Export Hex",
  * Then logout from Advanced mode

## Connecting the programmer

You're going to need to set the pins correctly, [this diagram from the docs
should be enough to figure it out][8]:

{% picture url: "resources/images/ikea-bekant-icsp-connection.png"
           alt: "Diagram of the pin connection between controller and PICkit"
           %}
  Pin connection between the controller and PICkit
{% endpicture %}

{% picture url: "resources/images/ikea-bekant-pins-set.jpeg"
           alt: "Photograph of the pins correctly set on the controller" %}
  Connecting the pins correctly
{% endpicture %}

Then, Click "Connect" in the main UI, and the programmer will attempt to
connect to the chip.

{% picture url: "resources/images/ikea-bekant-mplab-connecting.png"
           alt: "Screenshot of MPLAB connecting to the controller" %}
  MPLAB: Connecting
{% endpicture %}

I had some problems in ensuring there was a good connection. Leaning my finger
on the connector was good enough to solve that.

{% picture url: "resources/images/ikea-bekant-leaning-on-pickit.jpeg"
           alt: "Photograph of my finger pushing against the PICkit pins to
            ensure a good connection" %}
  My finger pushing the PICkit pins to ensure a good connection
{% endpicture %}

## Reading off the current firmware

Next, read off the existing firmware in case it goes horribly wrong.

{% picture url: "resources/images/ikea-bekant-mplab-reading-firmware.png"
           alt: "Screenshot of MPLAB reading the existing firmware" %}
  Screenshot of MPLAB reading the existing firmware
{% endpicture %}

[You can find the firmware from mine here][7].

## Flashing the new firmware

1. Fetch the firmware from the [releases page][6],
2. Load the firmware ("Hex File" → "Browse),
3. Program it: Click "Program",
4. Verify it: Click "Verify"

It should program and then verify successfully.

{% picture url: "resources/images/ikea-bekant-mplab-flashed-firmware.png"
    alt: "Screenshot of MPLAB after flashing and verifying the firmware" %}
  MPLAB: Flashing and verify the new firmware
{% endpicture %}

## Testing

To test it out, I first followed the advice in the docs and cleared enough
space for safety and then wired everything up in a way I could quick disconnect
it if things went wrong.

Then [I followed the rest of the guide][5] which involved testing out the
default buttons, followed by the memory the firmware has by default. Everything
worked out great! I can now press Up whilst pressing Down to move to the higher
position and Down whilst pressing Up to move down. The original commands all
work too.

All that was left to do was to mount the control unit back to the desk (this
time without the top cover).

[1]: https://github.com/ivanwick/bekantfirmware
[2]: https://www.amazon.co.uk/gp/product/B098D3VMDP
[3]: https://www.microchip.com/PIC16F1938
[4]: https://www.microchip.com/en-us/tools-resources/develop/mplab-x-ide
[5]: https://github.com/ivanwick/bekantfirmware/wiki/Installation-Guide#Test-new-firmware
[6]: https://github.com/ivanwick/bekantfirmware/releases/
[7]: /resources/ikea-bekant-original-firmware.hex
[8]: https://github.com/ivanwick/bekantfirmware/wiki/PICkit3#icsp-pin-connection
