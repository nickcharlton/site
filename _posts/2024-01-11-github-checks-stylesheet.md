---
title: "Always showing all GitHub Checks with a user style sheet"
tags: github project
---

If you've worked with pull requests on GitHub for a while &mdash; especially
with Actions &mdash; you're probably used to having a long list of checks,
that you find yourself scrolling every time to find the failing one:

{% picture url: "resources/images/github-checks-scrolling-box.gif"
           alt: "An animated gif showing a long list of checks on a GitHub Pull
           Request, where the user is scrolling up and down to find the one
           which is failing"
%}
  The usual view of GitHub checks when you've got a lot, and one failing
{% endpicture %}


Last year, [Ben][3] and I started working on a user style sheet to stop you
needing to scroll and instead show the whole section:

{% picture url: "resources/images/github-checks-expanded-box.png"
           alt: "A screenshot showing the state after the user style sheet is
           used, with the scrolling area expanded to fit the amount of checks."
%}
  After the user style sheet, with the scrolling area expanded to fit the
  amount of checks.
{% endpicture %}


I use [UserScripts][1] in Safari, but I've heard good things of [Stylus][2]
too. We came up with this:

```css
/* ==UserStyle==
@name        Expand GitHub PR Statuses
@description Always fully expand the statuses on the GitHub PR page
@match       https://github.com/*
==/UserStyle== */

/* don't restrict the height of the open state */
.branch-action-item.open > .merge-status-list-wrapper > .merge-status-list, .branch-action-item.open > .merge-status-list {
  max-height: none;
}

/* always expand to fill the content of the above */
.merge-status-list { max-height: none; }

/* collapse the hidden state */
.merge-status-list.hide-closed-list { max-height: 0; }
```

I've used this since November and it works great!

[1]: https://github.com/quoid/userscripts
[2]: https://add0n.com/stylus.html
[3]: https://eskola.uk
