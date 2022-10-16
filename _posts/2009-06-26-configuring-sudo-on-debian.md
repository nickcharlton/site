---
title: Configuring Sudo on Debian
tags: debian sudo security
---

Setting up sudo on Debian can seem daunting at first, but the process is really quite simple.

To do this you must use the command "visudo". Whilst you do not need to use "vi/vim" to do the actual editing (as it will use your preferred editor as listed in .bashrc), you will not be able to save changes.

From here you will see the config file. Under "# User alias specification" you will want to list the users required to access. You can comma separate values here.

	# User alias specification
	User_Alias STAFF nickcharlton, otheruser

Next, although optional, it is possible to specify the applications that the user can run.

	# Cmnd alias specification
	Cmnd_Alias DEB = /usr/bin/apt-get

Similarly, this section can be comma separated. On a system where it's users can be trusted at a higher level, it's not important to drill down tightly on these.

Next, you need to allow access under the "# User privilege specification". Where no commands have been specified it is appropriate to simply duplicate that of the root user.

	# User privilege specification
	root ALL=(ALL) ALL
	MAINTAINERS ALL = DEB
	STAFF ALL-(ALL) ALL

And that's it. Another simple task, which at first can seem a little daunting.

_Sources: [NewbieDoc: Configuring Sudo to Run Programs as Another User](http://newbiedoc.berlios.de/wiki/How_to_configure_Sudo_to_run_programs_as_a_different_user)_

