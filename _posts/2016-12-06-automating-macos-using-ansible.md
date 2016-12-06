---
title: "Automating macOS using Ansible"
published: 2016-12-06T14:05:08-05:00
tags: osx macos ansible configuration-management
---

I have a collection of macOS machines, some of which are used for services like
[Jenkins][] and others which are used for testing. These all have a consistent
base configuration which I've been using Ansible to configure.

Ansible is being used to to drive a set of utilities that have emerged to help
with some of the rougher edges of configuring macOS. In places where this
abstraction isn't available, I'm calling out to `defaults write` to set
settings directly. There's a [few][my_dotfiles] [examples][bynens_dotfiles] and
a [site dedicated][defaults_write] to figuring out what's possible.

I'm usually doing this in VMs, so I start by creating a new one using a set of
[Packer templates][] which create a base machine using a recent installer, runs
updates and installs an `ssh` key. From here, I'll then run an Ansible playbook
that will:

* Install [Homebrew][],
* Set the dock position, size and contents,
* Show devices on the desktop, align files to the grid, show hidden files, etc.

It ends up looking like this:

<figure>
  <img src="/resources/images/ansible_configured_macos_vm.png"
  alt="Ansible Configured macOS VM" max-width="500px">
  <figcaption>Ansible Configured macOS VM</figcaption>
</figure>


Some of these settings are the same on my own Macs, but most of these (like the
dock and it's contents) are all about making it as easy as possible to interact
with it over a screen sharing session and having something consistent across
the board.

To achieve these, I do this:

```yaml
---
- name: Base OS X configuration
  hosts: all
  roles:
    - geerlingguy.homebrew
    - base
```

This is the base playbook. It's held in a central `ansible` repo, but here
we're installing Homebrew (using [Jeff Geerling's Homebrew Role][hb_role]) and
then executing the base role. The base role looks like this:

{% raw %}
```yaml
---
- name: Install base utilities
  homebrew:
    name: "{{ item }}"
  with_items:
    - m-cli
    - dockutil

- name: Remove all items from the Dock
  shell: /usr/local/bin/dockutil --remove all

- name: Set the default Dock items
  shell: "/usr/local/bin/dockutil --add {{ item }} --no-restart"
  with_items:
    - /Applications/Safari.app
    - "\"/Applications/App Store.app\""
    - "\"/Applications/System Preferences.app\""
    - /Applications/Utilities/Terminal.app
    - /Applications/Utilities/Console.app
    - "/Applications --section others"
    - "~/Downloads --section others"

- name: Reduce the size of the Dock to 30 points
  shell: defaults write com.apple.dock tilesize -int 30

- name: Show the Dock on the left-hand side
  shell: /usr/local/bin/m dock position LEFT

- name: Disable the Screensaver
  shell: defaults write com.apple.screensaver idleTime 0

- name: Arrange Files by Kind
  shell: |
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy kind" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy kind" ~/Library/Preferences/com.apple.finder.plist

- name: Set the Grid Spacing for Files
  shell: |
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 54" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 30" ~/Library/Preferences/com.apple.finder.plist

- name: Use Smaller Icons
  shell: |
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 48" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist

- name: Show ~/Library
  shell: chflags nohidden ~/Library

- name: Show Drives on the Desktop
  shell: defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true

- name: Show External Drives on the Desktop
  shell: defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

- name: Show Removable Media on the Desktop
  shell: defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

- name: Show Hidden Files
  shell: defaults write com.apple.finder AppleShowAllFiles -bool true

- name: Show File Extensions
  shell: defaults write NSGlobalDomain AppleShowAllExtensions -bool true

- name: Show the Status Bar in Finder
  shell: defaults write com.apple.finder ShowStatusBar -bool true

- name: Show the Path Bar in Finder
  shell: defaults write com.apple.finder ShowPathbar -bool true

- name: Restart Finder
  shell: killall Finder
```
{% endraw %}

It relies on [m-cli][] and [dockutil][] to reconfigure the dock and then relies
on an Ansible form of some of my existing [dotfiles][] [defaults.sh][] script.
These commands need to be run inside a shell, so they're executed through
`shell` (only through `command` will cause them to fail).

Of note, I found that I now need to set the ordering of Finder items and their
size before showing additional devices. This wasn't the case before OS X 10.11.
(We need to use `PlistBuddy` because it's nested, but this doesn't seem to be
the reason for why.)

[Jenkins]: /posts/installing-jenkins-osx-yosemite.html
[my_dotfiles]: https://github.com/nickcharlton/dotfiles/blob/master/osx/defaults.sh
[bynens_dotfiles]: https://github.com/mathiasbynens/dotfiles/blob/master/.macos
[defaults_write]: http://www.defaults-write.com
[Packer templates]: https://github.com/nickcharlton/packer-osx
[Homebrew]: https://github.com/homebrew/brew
[hb_role]: https://github.com/geerlingguy/ansible-role-homebrew
[m-cli]: https://github.com/rgcr/m-cli
[dockutil]: https://github.com/kcrawford/dockutil
[dotfiles]: https://github.com/nickcharlton/dotfiles
[defaults.sh]: https://github.com/nickcharlton/dotfiles/blob/master/osx/defaults.sh
