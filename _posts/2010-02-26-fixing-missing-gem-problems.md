---
title: Fixing Missing Gem Problems on OS X
published: 2010-02-26 08:00:00 +0000
tags: 
---

*Disclaimer: This could potentially bugger up Ruby and Ruby Gems on your machine, proceed carefully.*

Recently I've been doing quite a few [REST](http://en.wikipedia.org/wiki/REST "Representational State Transfer - Wikipedia, the free encyclopedia") API building stuffs with [Ruby](http://www.ruby-lang.org/en/ "Ruby Programming Language"), [Sinatra](http://www.sinatrarb.com/ "Sinatra") and trying to pick up [ActiveRecord](http://ar.rubyonrails.org/ "Active Record -- Object-relation mapping put on rails") to use with Rails. I was however getting quite a lot of problems with Gems loading, but not loading completely.

If when running `gem check --alien`, you get something similar to below:

	rails-1.2.6 has 2 problems
		/Library/Ruby/Gems/1.8/specifications/rails-1.2.6.gemspec:
		Spec file doesn't exist for installed gem

		/Library/Ruby/Gems/1.8/cache/rails-1.2.6.gem:
		missing gem file /Library/Ruby/Gems/1.8/cache/rails-1.2.6.gem

Clear out all of the gems located in the following directories. You will need to similarly remove anything in the bin/, cache/, doc/, gems/ and specifications/ directories.

	/Library/Ruby/Gems/1.8
	/Users/<username>/.gem/ruby/1.8
	/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/gems/1.8
	
(These directories can be found by entering `gem environment`).

You will then need to reinstall all of your gems. You may wish to issue a `gem check` on each of them to ensure it's all good.

