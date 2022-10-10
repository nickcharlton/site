---
title: "Self-updating GitHub README"
published: 2022-10-10 10:00:00 +01:00
tags: ruby github
---

Back in 2020, [GitHub added profile READMEs][1]. I jumped on it and created
mine when they silently launched the feature but then did …nothing with it.

As the profile README is implemented as a special repository which gets
rendered on your profile page, I'd wanted to build something that would
auto-update and show contributions after [reading that Simon Willison had done
the same][3]. I was never going to remember to update these myself, but as it's
just a GitHub repo, we can use GitHub Actions to make it possible.

<figure>
  <img src="{{ '/resources/images/github-readme.png' | absolute_url }}"
    alt="Screenshot showing a GitHub README with contributions and blog posts" max-width="250px">
  <figcaption>GitHub README with contributions and blog posts</figcaption>
</figure>

## Fetching recent cross-GitHub activity

I often make contributions across various different repos and I thought it'd be
interesting to show these off. I might be working on something quite
interesting at work and usually when I do so, I end up opening issues or
contributing PRs to various things. I started off by trying to use the [GitHub
GraphQL API][5], but the complexity was a lot for a query which was better off
calling the [Search API][6].

I already have a [search I use to check what open issues and PRs I have][4]
that I should follow up with, so that was where I started:

```
is:open author:nickcharlton archived:false sort:updated-desc
```

We want archived items (to see closed or merged issues/PRs), but otherwise
that's what we pass through to the API:

```ruby
headers = {
  "User-Agent" => "Recent GitHub Contributions (#{username})",
  "Accept" => "application/vnd.github+json",
}

client = Excon.new("https://api.github.com/search/issues", headers: headers)

response = client.get(query: {
  "q" => "author:#{username} sort:updated-desc is:public", per_page: count
})
```

From here, I'm repacking as a `Contribution` object (which is just a PORO with
the keys below) so that it's a little easier to work with later on:

```ruby
data = JSON.parse(response.body, symbolize_names: true)

data[:items].map do |item|
  Contribution.new(
    id: item[:id],
    title: item[:title],
    url: item[:html_url],
    state: item[:state],
    type: item.has_key?(:pull_request) ? "pull_request" : "issue",
    created_at: item[:created_at],
    updated_at: item[:updated_at]
  )
end
```

One deliberate decision was to remove the `GITHUB_TOKEN` from the request
entirely to avoid the possibility of leaking private information. I have access
to a lot of repos and I wouldn't want to accidentally leak something that
shouldn't be. Fortunately, GitHub allows enough public access without a token.

You can [see the full implementation on GitHub][7].

## Pulling in an RSS feed

This one is relatively straightforward. My blog has an Atom feed and we can
pull that in and fetch the top five posts. I used [Feedjira][8], which seems to
be a well maintained RSS/Atom library which is able to handle malformed feeds
well to avoid other problems:

```ruby
client = Excon.new("https://nickcharlton.net/atom.xml")

response = client.get
feed = Feedjira.parse(response.body)

feed.entries.first(count).map do |entry|
  Contribution.new(
  id: entry.id,
  title: entry.title,
  url: entry.links.first,
  state: nil,
  type: nil,
  created_at: entry.published,
  updated_at: entry.updated,
  )
end
```

I figured re-using the `Contribution` object would be good enough — maybe it'd
be nice to make the GitHub contribution specific fields default to `nil` but
this will do.

You can [see the full implementation on GitHub][9].

## Assembling the README

This was much more fun to put together. In Simon's original, he used an HTML
comment to surround a block to replace and I did the same. So we'll have the
following in the `README.md`:

```html
<!-- contributions starts -->
<!-- contributions ends -->
```

Elsewhere, we'll assemble the line from the list of contributions and then we
can replace the text:

```ruby
replacement = <<~REPLACEMENT
  <!-- #{marker} starts -->
  #{content}
  <!-- #{marker} ends -->
REPLACEMENT

document.gsub(
  /<!\-\- #{marker} starts \-\->.*<!\-\- #{marker} ends \-\->/m,
  replacement.chomp
)
```

We're able to use the `marker` to use the same code to update multiple
sections, which is nice. You can [see the full implementation on GitHub][10].

## Building using GitHub Actions

GitHub Actions has a bunch of nice features we can use here. To start with,
Actions are able to make changes to the repository that they're running on, so
we can use the `git` commands without configuring more than the name and email
address. Next, we can use the `schedule` event to regularly trigger an update.
I chose daily at 11am — I don't make enough contributions for any more to be
beneficial. I also configured `workflow_dispatch` so that I could manually
trigger it if I so desired.

I had a bit of a chicken and egg problem in doing this. I wanted to test the
Action on `push` to make sure it was working, but didn't want the README
changes to get picked up when merging. I ended up making sure it works, then
deleting that commit, removing the push trigger and running it manually after.
Anyway, here's how it works:

```yaml
---
name: Update README

on:
  workflow_dispatch:
  schedule:
    - cron: '0 11 * * *'

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Set up Ruby
      uses: ruby/setup-ruby@v1
      with:
        bundler-cache: true
    - name: Install dependencies
      run: bundle install
    - name: Update README
      run: |-
        bin/update_readme
        cat README.md
    - name: Commit and push if changed
      run: |-
        git diff
        git config --global user.email "actions@users.noreply.github.com"
        git config --global user.name "README Bot"
        git add -A
        git commit -m "Updated content" || exit 0
        git push
```

So now I have an auto-updating GitHub README which shows up on my profile. [Go
take a look][11]!

[1]: https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-github-profile/customizing-your-profile/managing-your-profile-readme
[2]: https://github.com/nickcharlton/nickcharlton/commit/a7aa55a83821e84b31a1b889e2dcfdab6447c745
[3]: https://simonwillison.net/2020/Jul/10/self-updating-profile-readme/
[4]: https://github.com/pulls?q=is%3Aopen+author%3Anickcharlton+archived%3Afalse+sort%3Aupdated-desc
[5]: https://docs.github.com/en/graphql
[6]: https://docs.github.com/en/rest/search
[7]: https://github.com/nickcharlton/nickcharlton/blob/6ece45c2791a4197e047beedb9e97b5a008f6f20/lib/github_contributions.rb
[8]: https://github.com/feedjira/feedjira
[9]: https://github.com/nickcharlton/nickcharlton/blob/6ece45c2791a4197e047beedb9e97b5a008f6f20/lib/rss_feed.rb
[10]: https://github.com/nickcharlton/nickcharlton/blob/6ece45c2791a4197e047beedb9e97b5a008f6f20/lib/readme.rb
[11]: https://github.com/nickcharlton
