---
title: Mirroring Bazaar Repositories with Git
tags: git bazaar
---

[Ubuntu][] uses [bazaar][] as it's source control system, with [Launchpad][] as
the hosting service. This is fine, apart from when you want to include
something which is maintained in [Git][] or otherwise doesn't have good enough
support for it. In my case, I wanted to mirror a repository on GitHub so that
it could be included elsewhere as a submodule.

Bazaar provides [dpush][] for this, but it wasn't so obvious at first sight how
to work with it. (Replace `example` with the appropriate name):

### 1. Ensure You've Got the Git Plugin

The Git plugin provides the interoperability you'll need. Some package
repositories will have as `bzr-git` ([like Ubuntu does][bzr_git_ubuntu]). You
may need to [install it manually][bzr_plugins].

Something like this, perhaps:

```sh
cd ~/.bazaar/plugins
bzr branch lp:bzr-git git
```

(You may need to create the `plugins` directory.)

You'll probably also have to install `dulwich`: `pip install dulwich`.

### 1. Clone the Bazaar Repository

```sh
bzr branch lp:example example
```

### 2. Create a Git Repository

You can create this where ever you usually create your hosted repositories.

All you'll need is the URL given to you to create the repo, in this case:

```
ssh://git@github.com/nickcharlton/example.git
```

I was unable to use this directly, so instead gave `bzr` a hint by adjusting it
to:

```
git+ssh://git@github.com/nickcharlton/example.git
```

### 4. Push the Clone to the Remote

The final step is to push the repository, including using the conventional
branch:

```sh
bzr dpush -v git+ssh://git@github.com/nickcharlton/example.git,branch=master
```

With Python installed via `brew`, I needed to ensure `$PYTHONPATH` was set
correctly, to the following:

```sh
export PYTHONPATH="/usr/local/lib/python2.7/site-packages"
```

You should now have a full copy of all of the original `bazaar` history, but
now all configured with `git`.

[Ubuntu]: http://www.ubuntu.com
[bazaar]: http://bazaar.canonical.com/en/
[Launchpad]: https://launchpad.net
[Git]: http://git-scm.com
[dpush]: http://doc.bazaar.canonical.com/bzr.2.6/en/user-reference/dpush-help.html
[bzr_plugins]: http://doc.bazaar.canonical.com/plugins/en
[bzr_git_ubuntu]: http://packages.ubuntu.com/trusty/bzr-git
