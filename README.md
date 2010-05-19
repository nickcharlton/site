# Sinba: A Blogging Engine in Ruby.

Sinba is a blogging engine inspired by [Tumblr](http://www.tumblr.com/ "Tumblr"), [Markdoc](http://markdoc.org/ "Markdoc Documentation » 
        Index"), [Chirp](http://chyrp.net/ "Chyrp") & [Jekyll](http://jekyllrb.com/ "jekyll"). It's designed around short blogging, and blogging code. It's based upon Sinatra.

It uses erb for templating, ActiveRecord for storing posts (and SQLite, MySQL, Postgres, etc), Markdown for markup, Google's Code Prettify for syntax highlighting & Facebox for modal windows.

# Features

_none_

# Documentation

It's a Sinatra app, so, you can deploy it onto somewhere like Heroku, or [read here about deploying Sinatra](http://sinatra-book.gittr.com/#deployment "Sinatra Book").

## Admin Section.

Navigate to /admin and you'll be asked to login. 

It supports more than one user for authentication, but no privileges. You can either login and do anything, or do nothing.

Once you've logged in, you'll be redirected to the frontpage, where you will be able to see some more options. These will load a modal window for the option you chose, over the rest of the site.

## The Rest.

You should just be able to see the rest out of the box. On first load, it'll create all of your database tables, and pull in layouts and templates. It follows the Rails convention of /views and /public/stylesheets & /public/javascript for additions.

# Version History

* 0.1: Initial version, supporting just the basics.