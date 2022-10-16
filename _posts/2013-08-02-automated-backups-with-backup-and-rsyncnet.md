---
title: Automated Backups with backup and Rsync.net
tags: sysadmin backups ruby
---

For the past 18 months, I've been meaning to review the way I go about doing backups.
Whilst I'm quite settled on backing up workstations, until about two weeks ago I
had a half-configured, non-recoverable solution which was only setup on one out of
several servers. That's not very useful. 

As well as the obvious requirement for something automated, I also wanted something 
which could allow me to reuse much of the backup definitions across multiple servers
but also allowed me to avoid writing bash scripts. I'd come across the [`backup`
Ruby gem][gem] some time ago and after some quick testing, this seemed to work
quite well.

Then, I needed some sort of remote host to backup to. I had heard of [Rsync.net][] 
through the [prgmr][] mailing list. They provide a reasonably cheap remote filesystem
with which you can access over `ssh` (and so, `scp` and `rsync` work). On the machine
being backed up, this is great as I don't need any special tools to upload backups
and for restoring the same applies. 

## Backup Strategy

The `backup` gem uses the concepts of "models" to define a "backup". This consists
of any directories or databases you may wish to backup, along with any processing
you may wish to do with it (compressing, encrypting, etc) and where to store it.

My approach to the models is to create different ones for the different "roles" a system
performs. By default, this includes a "base" role which archives `/etc`, `/home`
and `/var/log` (in a multi-user system, I'd probably split out `/home` to it's own
model). Then, additional models are defined for more specific roles. So, to backup
a Wordpress site, a "site" model would first backup the associated database and
then collect up the data in `/var/www/site/` into the one archive.

Each model is set to be compressed using `gzip`, upload to [Rsync.net][] and then 
notify me if any errors occur. It also keeps the last 5 versions of the backup.

`backup` handles organising the subsequent archives on the remote quite well. For
each server, I define a directory to collect them in and then `backup` sorts each
run by a directory named after the timestamp. Each model is then collected inside.
Much like this:

```
server_name/
    base/
        2013.07.29.21.54.01/
            base.tar
        2013.07.30.00.30.07/
            base.tar
```

Finally, a cron job is used to automate it to run daily.

## rsync.net

[Rsync.net][] is refreshingly simple (a bit like [prgmr][] is, I suppose). After
signing up, you'll get sent the details needed to access the relevant box, where you
can `ssh` in, and do the basics (change the password, check your quota usage, move
files, create directories, etc.).

I opted for a geographically distributed plan (it's slightly more expensive, but it
is the primary backup method I'm using) and the lowest plan &mdash; the amount of
data is tiny as it's mostly text files.

And that's essentially it. I paid for a year so I'll be reminded about it next year
to go about renewing it.

## `backup`

The [`backup` Ruby gem][gem] gives you a command line tool which will help generate 
the models and run them. But you should just install it as a gem, rather than using
Bundler or anything else.

I did all of this under a specific `backup` user. This is configured to allow it to
use `tar` through `sudo` without asking for a password and not much else. It expects
the backup models and configuration files to exist in `~/Backup/`, so this seemed
the best approach.

```bash
gem install backup
```

The documentation suggests using the model generator to get started and that's
pretty much what I did:

```bash
backup generate:model -t base --archives --storages='scp' --compressors='gzip' --notifiers='mail'
```

This will give a rather detailed and well commented example. I started with this
and stripped it down to the bare essentials. If you don't have one already, it will
also create a template `config.rb`, which will contain a similar set of examples.
`config.rb` can be used to set defaults for the models, so I opted to fill this with
as much as possible.

But, some Real World&trade; examples are much more useful:

### `base.rb`

```ruby
##
# Base: Basic Linux backup model.
# Archives and compresses: /etc, /var/log, /home, /mail.
# Uploads to rsync.net.
#
# $ backup perform -t base
##
Backup::Model.new(:base, 'Basic Linux Model') do
  # archive
  archive :etc do |archive|
    archive.use_sudo
    archive.add "/etc/"
  end

  archive :logs do |archive|
    archive.use_sudo
    archive.tar_options '--warning=no-file-changed'

    archive.add '/var/log'
  end

  archive :home do |archive|
    archive.use_sudo
    archive.add '/home'
    # don't backup up the backup data.
    archive.exclude '/home/backup/Backup/.tmp/'
  end

  archive :mail do |archive|
    archive.use_sudo
    archive.tar_options '--warning=no-file-changed'

    archive.add '/var/mail'
  end
  
  # compressor
  compress_with Gzip

  # storage
  store_with SCP

  # notifier
  notify_by Mail
end
```

The `archive` blocks are just an abstration over `tar`, so you can pass through
options. In this case, I've ignored file change warnings for areas which are likely
to not harmfully change whilst the backup is running.

Both the storage and notifier lines assume the configuration has already been made.
If you didn't have these in `config.rb`, it wouldn't work and you'd need to expand
the line into a block.

### `config.rb`

```ruby
##
# SCP Storage Type Defaults
##
Backup::Storage::SCP.defaults do |server|
  server.username   = ""
  server.ip         = ""
  server.port       = 22
  server.path       = "~/server_name/"
  server.keep       = 5
end

##
# Notifier Defaults
##
Backup::Notifier::Mail.defaults do |mail|
  mail.from                 = ""
  mail.to                   = ""
  mail.address              = "smtp.gmail.com"
  mail.port                 = 587
  mail.domain               = ""
  mail.user_name            = ""
  mail.password             = ""
  mail.authentication       = "plain"
  mail.encryption           = :starttls
end

# * * * * * * * * * * * * * * * * * * * *
#        Do Not Edit Below Here.
# All Configuration Should Be Made Above.

##
# Load all models from the models directory.
Dir[File.join(File.dirname(Config.config_file), "models", "*.rb")].each do |model|
  instance_eval(File.read(model))
end
```

The `scp` block contains the details for [Rsync.net][]. The mail defaults are
currently set to the values for Gmail's SMTP server (you'll need to fill in all of
the other relevant bits). By default, this will notify about all events (successful,
with warnings or a failure). I kept this like this for about two weeks to confirm
it was running correctly.

### Aside: Criticism

1. The configuration files would be more appropriately stored in `/etc`, given it's
    designed for Unix-like systems.
2. The timestamps are annoying. Unix timestamps or [ISO 8601][dateformat] is far 
    more appropriate than defining *another* bloody date format.

## Automation

To automate it, I just have a `crontab` entry under the `backup` user. This then
runs at 0130 every morning and emails me if necessary.

```cron
30 01 * * * backup perform -t base,www >/dev/null
```

(By default, it writes a lot to `stdout`, I'd rather not fill up an unmonitored
inbox with successes…)

I configured this about two weeks before writing up this blog post. It's been working
well since then, and I've deployed a similar configuration across at least two other
boxes.

I now need to investigate the [Chef cookbook][] and modify it to work similarly to
this…

[gem]: https://github.com/meskyanichi/backup
[Rsync.net]: http://www.rsync.net/
[prgmr]: http://prgmr.com/
[dateformat]: https://en.wikipedia.org/wiki/ISO_8601
[Chef cookbook]: https://github.com/cramerdev/backup-cookbook
