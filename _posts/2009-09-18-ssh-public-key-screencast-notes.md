---
title: SSH Public Key Screencast Notes
published: 2009-09-18 08:00:00 +0000
tags: ssh, security, screencast
---

_These are just a few quick notes to accompany [Peter Upfold's screencast](http://vimeo.com/6523718). If you haven't ready I would suggest you give it a watch before following this rather brief notes_

## On the local machine ##

1. run: `ssh-keygen -t rsa`
2. Accept default path.
3. Enter a passphrase. (terminal can save this in Keychain)
4. Finder > Go > Type: ".ssh"
5. Copy `id_rsa.pub`

## On the remote machine ##

1. run: `touch .ssh/authorized_keys`
2. Edit the file: `.ssh/authorised_keys`
3. Paste the contents of the `id_rsa.pub` file into `.ssh/authorized_keys`

## Permissions Check ##

* The `authorized_keys` file needs to be `rw` for the user. 
* That is `chmod 600` to change, if needed.

## Logging in ##

* Login as usual from the Terminal. 
* When asked for the password to the ssh key, this is the passphrase mentioned earlier.

_Once again, thank you, [Peter](http://peter.upfold.org.uk) for recording it for me, and the mention._

