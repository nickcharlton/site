---
title: Conditionally Chaining ActiveRecord Queries
published: 2015-03-11 09:22:51 +0000
tags: ruby, rails, activerecord
---

Sometimes, [ActiveRecord][] queries can get pretty complex, especially if
you're implementing a feature like search over a typical "index" page that also
has pagination and the term itself is optional. Fortunately, ActiveRecord
queries can be chained in a few ways to make this a little bit nicer.

The most common is like:

```ruby
user = User.where(name: 'Nick Charlton').limit(1)
```

Which you'll see often. But you can also do something like this, which works
really well for more complex queries:

```ruby
user = User.where(name: 'Nick Charlton')
user = user.where(email: 'nick@nickcharlton.net')

user #=> <User id: 1, name: 'Nick Charlton'>
```

The result isn't evaluated until you use the resulting object and so the
queries will be combined for you. This is because it returns an
`ActiveRecord::Relation` object, and not the fully evaluated query.

This can be a much cleaner solution to conditional filtering of records, like
you might wish to do with a reasonably complex search interface:

```ruby
articles = Article.where(published: true)
articles = articles.search('thing') if params[:term]
```

I'm following this pattern on a few projects where I'd previously branched on
the parameters given, but this is pretty unwieldy and leads to you duplicating
a bunch of code. This is much better.

[ActiveRecord]: http://guides.rubyonrails.org/active_record_querying.html
