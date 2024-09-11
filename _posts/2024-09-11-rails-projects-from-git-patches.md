---
title: "Generating Rails projects from Git patches"
tags: rails git
---

A couple of weeks ago, [Joel asked][4]:

> Starting a new rails app is fun!
>
> But after setting my bespoke set of preferred gems and config for the
> N-hundred’th time I think it may be time for some sort of
> template/generator/whatever.
>
> Any tips?

So, [I mentioned the approach I've used several times recently, using `git`'s
`format-patch` feature][5], but it really needs walking through to understand
how this is done.

Patches are how you sent commits over email, something still done on a lot of
projects but gradually becoming more esoteric. But they're very helpful. It's a
plain-text file with the commit information (author, time, message) and the
change set from that commit. The key commands are [`format-patch`][6] to create
the patches, and [`am`][7] which lets you apply them.

To do this, we start with an existing, sort of "template" project that's setup
how you'd like. But typically, I'll fetch from the last one I took this
approach with. The key bit is having well isolated and phrased commits, like
this:

```sh
$ git show 020090b
commit 020090b47d75d3e77c9ee55518e5fcd9074d5c53
Author: Nick Charlton <nick@nickcharlton.net>
Date:   Mon Feb 26 14:31:59 2024 +0000

    Setup a Rails app (#1)

    rails new TemplateProject --database postgresql --skip-keeps \
          --skip-action-mailbox --skip-action-text --skip-active-storage \
          --skip-action-cable --skip-hotwire --skip-jbuilder

    Plus: RSpec, FactoryBot, lograge, rack-timeout, flashes and i18n test
    configuration.
```

Here's the first few items of `git` history for a project I put together at
the start the year to experiment with an idea, which served as the "template
project":

```sh
$ git log --oneline
1f26eed (HEAD -> main, origin/main, origin/HEAD) Enable UUID primary keys (#6)
4d8dd1c Accept connections from an external tunnel (#5)
96f4241 Setup Ruby linting with standardrb (#4)
a3d0e2a Setup Bundle Audit (#3)
5bce041 Setup GitHub Actions for running tests (#2)
020090b Setup a Rails app (#1)
dc277a8 Initial commit; add README
```

These commits are were themselves from a another project I'd thrown together to
experiment with something completely different, and the one before _that_ was
when I sat down and figured out the bits I really cared about in Rails
projects. But they're all from around the same era — it's all Rails 7.1.

We can generate patches up to the "initial commit" — the first commit in a Git
repository is special, so we want to avoid that — and then apply them to
another project:

```sh
$ git format-patch dc277a8
0001-Setup-a-Rails-app-1.patch
0002-Setup-GitHub-Actions-for-running-tests-2.patch
0003-Setup-Bundle-Audit-3.patch
0004-Setup-Ruby-linting-with-standardrb-4.patch
0005-Accept-connections-from-an-external-tunnel-5.patch
0006-Enable-UUID-primary-keys-6.patch
```

I'll create a new branch, then apply the patch: `git am
0001-Setup-a-Rails-app-1.patch`. As long as you apply them in the order they
were written, they'll apply cleanly. If not, you can always modify the diff
inside the patch. Then, I'll go ahead and modify that commit until it's in the
state I want it to be:

1. Change any name references to the new project,
2. Run `bin/setup` and check it works,
3. Run `bin/dev` and check it works,
4. Update any gems that need updating, to save needing to do it immediately after,
5. Finally, before merging this branch, I'll update the author/commit dates to
   avoid confusing myself in future (e.g.: `git commit --amend --date=now`)

In this example, the other patches generated are around linting, GitHub Actions
for CI, Bundle Audit to catch vulnerable dependencies and some others like
`UUID` primary keys. In the project I'm creating whilst writing this, I don't
care about `UUID` so I'll just skip that but I'll want the rest.

I'll caveat this approach, however, with a _you probably shouldn't do it this
way_. From maintaining [Administrate][2] and having many ideas I'd like to try
out, I create a lot of throw-away Rails projects.

For many years, I'd used [Suspenders][1] but it went through a period where
using it was pretty unreliable as we were struggling to keep up with Rails
changes. Now we're at the end of 2024, we've fixed that, Suspenders is once
again in a good place and there's been a big boon in [Rails Templates][3] too.
But now you know you can do it completely differently, if you fancied it.

[1]: https://github.com/thoughtbot/suspenders
[2]: https://github.com/thoughtbot/administrate
[3]: https://guides.rubyonrails.org/rails_application_templates.html
[4]: https://ruby.social/@jayroh/112893332809536544
[5]: https://mastodon.nickcharlton.net/@nick/112893484600600333
[6]: https://git-scm.com/docs/git-format-patch
[7]: https://git-scm.com/docs/git-am
