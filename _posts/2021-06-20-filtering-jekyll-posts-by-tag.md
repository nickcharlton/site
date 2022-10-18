---
title: "Filtering Jekyll Posts by Tag"
tags: jekyll ruby
---

I'm doing a bit of spring cleaning around here, and I wanted to split the list
of posts on the index into _Week Notes_ and everything else. I differentiate
_Week Notes_ posts from others by tagging them with `week-notes` and filtering
by these seemed easily enough. But I was wrong.

In Jekyll, posts exist in a collection called `site.posts`, which you could
pipe into a [filter to change the list returned][1], so you could get a list
of _Week Notes_ posts by doing:

{% raw %}
```ruby
{% assign posts = site.posts | where_exp: "item", "item.tags contains 'week-notes'" %}
{% for post in posts limit:5 %}
  {{ post.title }}
{% endfor %}
```
{% endraw %}

Unfortunately, you [can't negate the expression as it's not been implemented
and doing so seems like it would break some established patterns][2]. You
_can_ do something like `unless post.tags contains 'week-notes'` inside the
loop, but this would mean we can't limit the amount of posts we try to render
which is both awkward and inefficient.

Fortunately, it's not too difficult to [build your own filter][3] and so I came
up with:

{% raw %}
```ruby
{% assign posts = site.posts | filter_posts: "tags", "include 'week-notes'" %}
```
{% endraw %}

…which is similar to `where_exp`, but more specific to filtering posts; I
didn't want to get too deep into parsing expressions, so I used a regular
expression and a bit of meta programming to get something which works nicely:

```ruby
module Jekyll
  module FilterPosts
    def filter_posts(posts, attribute, expression)
      method_name, key = expression.scan(/(\w*)\s?'([\w-]*)?'/).first

      method = case method_name
               when "includes"
                 :select
               when "excludes"
                 :reject
               else
                 nil
               end

      return [] unless method

      posts.send(method) { |post| post.data[attribute].include?(key) }
    end
  end
end

Liquid::Template.register_filter(Jekyll::FilterPosts)
```

```ruby
RSpec.describe Jekyll::FilterPosts do
  include Jekyll::FilterPosts

  describe "tags" do
    it "can filter by presence of tags" do
      document1 = double("Jekyll::Document", title: "Post 1",
                                             data: { "tags" => ["week-notes"] })
      document2 = double("Jekyll::Document", title: "Post 2",
                                             data: { "tags" => ["projects"] })

      posts = filter_posts([document1, document2],
                           "tags",
                           "includes 'week-notes'")

      expect(posts).to match_array([document1])
    end

    it "can filter by exclusion of tags" do
      document1 = double("Jekyll::Document", title: "Post 1",
                                             data: { "tags" => ["week-notes"] })
      document2 = double("Jekyll::Document", title: "Post 2",
                                             data: { "tags" => ["projects"] })

      posts = filter_posts([document1, document2],
                           "tags",
                           "excludes 'week-notes'")

      expect(posts).to match_array([document2])
    end

    it "is empty if the filter method is invalid" do
      document1 = double("Jekyll::Document", title: "Post 1",
                                             data: { "tags" => ["week-notes"] })
      document2 = double("Jekyll::Document", title: "Post 2",
                                             data: { "tags" => ["projects"] })

      posts = filter_posts([document1, document2],
                           "tags",
                           "something 'week-notes'")

      expect(posts).to match_array([])
    end
  end
end
```

A `Jekyll::Document` has a `data` hash which we can ask for information about
the post, so `attribute` here is calling that. I didn't test for it, but you
could presumably filter for other things as well as tags. For testing,
[you'd usually want to test the output of the filter][4], but in this case
it's a collection and so it seemed much easier to do that directly.

You can see it all tied together in [the PR which added it][5].

[1]: https://jekyllrb.com/docs/liquid/filters/
[2]: https://github.com/Shopify/liquid/issues/138
[3]: https://jekyllrb.com/docs/plugins/filters/
[4]: https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers#create-your-own-filters
[5]: https://github.com/nickcharlton/nickcharlton.net/pull/77
