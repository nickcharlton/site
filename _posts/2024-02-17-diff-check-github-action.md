---
title: "diff-check: A GitHub Action which fails if anything changed"
tags: project github-actions
---

Last year, I started to see a few common workflows that would create more work
by those unaware or open yourself up to making annoying mistakes if you did,
that I thought could be caught with just a little more automation.

This was typically when [Dependabot][2] would go and bump a dependency that
would have other implications: for example, if you bump a `npm` dependency in a
React Native project, it might change the `Podfile.lock` in the iOS portion of
the codebase, or if you bump a dependency used by [Appraisal][1], one of it's
generated files could change. It gets pretty annoying for everyone else if you
merge in that seemingly okay Dependabot PR and then someone (even if it's
yourself) has to go and add another commit to add in the forgotten lock file
change.

To try and tackle this, I've put together a GitHub Action called "diff-check".
It runs a command and fails if anything subsequently changes. For example, you
might create a workflow that looks like this:

```yaml
---
name: diff-check
on: [push]

jobs:
  demo:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: nickcharlton/diff-check@main
        with:
          command: echo "hello world" >> README.md
```

It would then fail because `README.md` changed and report on the summary page:

{% picture url: "resources/images/diff-check-demo.png"
           alt: "A screenshot of the Action 'diff-check' reporting the results
           of how it run, displaying that the 'README' file had changed."
%}
  The demo running and showing the job summary.
{% endpicture %}


At its heart, [it's a fairly short shell script][5], that's [called by the action][6]:

```sh
#!/bin/sh

set -e

if ! git diff-index --quiet HEAD; then
	printf 'These files changed when running the command:\n\n'

	git diff --name-only | while read -r n ; do
		echo "* $n"
	done

	exit 1
fi
```

But there's enough logic in here that I really wanted some tests to make sure
it was correct. I turned to [Oli's `jet_black`][3], which I've been meaning to
try out for years and let me write some tests using RSpec. [I'm pretty happy
with how that turned out][7].

Trying to solve problems like these in such an abstract way is far harder than
first solving a specific problem. I'd originally created the repo back in July
of last year, and I really wanted the implementation to be able to suggest what
needed to be done through a review suggestion, but this [isn't possible despite
a long-standing feature request for it][4]. In the end, this was the common
thread through the situations I kept seeing. Hopefully it might help out some
others too.

[1]: https://github.com/thoughtbot/appraisal
[2]: https://docs.github.com/en/code-security/dependabot/working-with-dependabot
[3]: https://github.com/odlp/jet_black
[4]: https://github.com/orgs/community/discussions/9099
[5]: https://github.com/nickcharlton/diff-check/blob/838eaa28f7bb1deb61479f75cf80bafcda0a7433/bin/diff-check
[6]: https://github.com/nickcharlton/diff-check/blob/838eaa28f7bb1deb61479f75cf80bafcda0a7433/action.yml
[7]: https://github.com/nickcharlton/diff-check/blob/838eaa28f7bb1deb61479f75cf80bafcda0a7433/spec/black_box/diff-check_spec.rb
