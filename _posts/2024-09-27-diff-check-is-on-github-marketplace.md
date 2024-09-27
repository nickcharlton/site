---
title: "diff-check is on GitHub Marketplace"
tags: project github-actions
---

Today, I cut the [first release (v1.0.0)][3] and [published diff-check to
GitHub Marketplace][2].

[`diff-check`][4] came out of seeing a common pattern of seeing side effects
when another automated process would run, creating more work which wouldn't be
seen at the time. It was really common when I was working on React Native
projects (if you upgrade an `npm` dependency, you'll often get a change in the
`Podfile.lock` that Dependabot wouldn't know about), but less frequently in
projects using Appraisal (another project I maintain). I [previously wrote up
how it works in the announcement blog post][1].

With some help from [Oscar Gustafsson][5] (thank you!), he helped see some bits
I'd got wrong and also pointed out some small ways in which we could improve
the output too. Several weeks ago, [I'd also merged in a PR to use this on
Administrate][6] and so now I'm pretty happy it's working.

I'd love to hear if it works out for you!

[1]: https://nickcharlton.net/posts/diff-check-github-action
[2]: https://github.com/marketplace/actions/diff-check
[3]: https://github.com/nickcharlton/diff-check/releases
[4]: https://github.com/nickcharlton/diff-check
[5]: https://github.com/oscargus
[6]: https://github.com/thoughtbot/administrate/pull/2609
