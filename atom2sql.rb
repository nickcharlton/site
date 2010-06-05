# A little tool to take an Atom feed, tidy it up in a few places, then
# spit it back out as an SQL INSERT statement.
#
# Usage: ruby atom2sql.rb > atom.sql
#
require "rubygems"
require "simple-rss"
require "open-uri"
require "fast_xs"

# format our given time to work as MySQL wants
def mysqltime(from)
  to = from.strftime("%Y-%m-%d %H:%M:%S")
  # Example: 2010-05-30 00:42:13
  return to
end

# trim out the URLs so only the important bit is kept
def trim_url(url)
  # takes out anything other than the final /url section of the url
  trimmed = url.split("/")
  
  return trimmed.last
end

# escape all of our / and '
def quote (str)
  str.gsub(/\\|'/) { |c| "\\#{c}" }
end

# pull in the file (you can use a url here)
atom = SimpleRSS.parse open("atom.xml")

# define the start of our statement (note; we're relying on auto_increment here.)
sql = "INSERT INTO posts (title, content, author, url, created_at, updated_at) VALUES \n"

# build up the sql for the entries
for entry in atom.entries
  sql = sql + "('#{quote(entry.title)}', '#{quote(entry[:content])}', 1,'#{trim_url(entry.link)}', '#{mysqltime(entry.updated)}', '#{mysqltime(entry.updated)}'), \n"
end

# remove the last comma, and related crud
sql = sql.chop.chop.chop

# finish off the statement
sql = sql + "; "

# print it out
puts sql