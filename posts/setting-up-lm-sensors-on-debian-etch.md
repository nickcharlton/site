---
title: Setting Up lm-sensors on Debian Etch
published: 2008-06-24T08:00:00Z
tags: 
---

lm-sensors is a package which provides temperature monitoring under Linux. This guide explains how to setup lm-sensors under Debian Etch.

To install it under Debian, use:

	apt-get install lm-sensors

Although there are other pre-requisites, a default install of Etch will work quite nicely.

Next, you need to load the i2c-dev module. This allows you to access some of the chips on your motherboard which are hooked up to temperature sensors.

	modprobe i2c-dev

Now you need to detect the sensors on your system using the wizard in the following command. I just stack to the defaults.

	sensors-detect

At the end of this you will be told a list of devices, these need to be loaded too, as an example:

	modprobe -a i2c-viapro i2c-isa eeprom w83627hf

By loading the:

	sensors

app you will be thrown at with a list of devices, it will also tell you some voltages, however for me the CPU temp, fan sped, and system temperature.

Hard Disk temperature can also be watched, this is slightly easier however as you simply need to install hddtemp and specify the drives.

	apt-get install hddtemp

	hddtemp /dev/hd?

if your system sees your drives as SCSI, or you have SCSI drives that is...

_Produced in aid of: [http://www.debian-administration.org/articles/327](http://www.debian-administration.org/articles/327)_

