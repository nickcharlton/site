---
title: "Making Drafts' Action Bar fit my workflow"
published: 2021-03-08 18-01-37 +00:00
updated_at: 2022-10-16T20:18:43+01:00
tags: drafts
---

I use [Drafts][6] for capturing text (everything from quick notes to this blog
post started there). I've been using Drafts for a year, and over that time,
it's become integral to my workflow. But I'd not done much to customise it to
fit what I regularly do.

I typically have a view that looks like this:

{% picture url: "/resources/images/drafts-main-window.png"
           alt: "A screenshot showing the Drafts editor area with the Action
                 Bar shown at the bottom" %}
  Drafts Main window, showing the editor area with Action Bar at the bottom
{% endpicture %}

I use _Flags_ to keep many notes at the top of the pile and Workspaces as a
context (but typically show everything in the _Inbox_). As I have Drafts take
up a quarter of my display, I always have the Actions sidebar hidden to
maximise note space. But the exciting bit is what I ended up doing with the
_Actions Bar_, which shows just below the note itself.

Outside of just being an excellent editor for notes, the real power of Drafts
is in _Actions_. I use very few in practice, but the ones I have, I find myself
using a lot. After having this workflow for a year, I've finally gotten a good
idea of what to do and made the _Actions Bar_ reflect it.

I started by creating a new group — I just called mine "Default" as it was the
first appropriate word that came to mind — and then moved the most common set
of actions I remember myself using to end up with a list which is:

1. Tasks (which turns a line into a checkbox: `- [ ] Item`),
2. Insert Date,
3. [Markdown Reference Link][2],
4. Markdown Table (generates a table, which I can never remember how to do),
5. Sort (which sorts alphanumerically),
6. Copy as Rich Text,
7. Copy as HTML,
8. Public Gist (this and the next is the _[Post Gist to GitHub Action][1]_),
9. Private Gist,
10. Preview (which pops open an HTML preview of the note),
11. [Selection to Draft][3] (which takes the current selection and makes a new
    Draft from it; great for breaking out notes),
12. [To Things][4] (which creates an item in [Things][5] with the title and
    description)
13. [Move Line Up][7] (`Opt-↑`)
14. [Move Line Down][8] (`Opt-↓`)
15. [Indent Line][9] (`⌘-]`)
16. [Outdent Line][10] (`⌘-[`)

The ones without links are already part of Drafts. To do this, I moved the
originals from their groups into the new one. It didn't seem worth doing
anything else more complex.

The final four I mostly use when outlining or making notes which might cover
lots of topics but which don't need to be expanded out too much. 1-on-1s are a
good case of these.

The real power of tools like Drafts is in the way you can customise and then
mix-and-match scripts to do stuff for you. But also, this is perhaps your
general reminder to go back to evaluate what you use regularly and optimise it
for how you use it now!

[1]: https://actions.getdrafts.com/a/18O
[2]: https://actions.getdrafts.com/a/1L4
[3]: https://actions.getdrafts.com/a/1ah
[4]: https://actions.getdrafts.com/a/1CO
[5]: https://culturedcode.com/things/
[6]: https://getdrafts.com
[7]: https://directory.getdrafts.com/a/2B3
[8]: https://directory.getdrafts.com/a/2B4
[9]: https://directory.getdrafts.com/a/1Bw
[10]: https://directory.getdrafts.com/a/1By
