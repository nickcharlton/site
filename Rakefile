#!/usr/bin/env rake

begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
end

desc "Deploy"
task :deploy do
  puts "Cleaning and then building..."

  system("bundle exec jekyll clean")
  system("bundle exec jekyll build")

  puts "Running Rsync..."
  system("rsync -avzc _site/ nickcharlton.net:/var/www/nickcharlton.net")
end

desc "Create a New Post"
task :new do
  require "date"
  post_date = DateTime.now

  puts "What will the new post be called? (e.g.: A New Post)"
  post_name = STDIN.gets.chomp

  puts "What should the slug be? (e.g.: a-new-post)"
  post_slug = STDIN.gets.chomp

  puts "What should it be tagged with? (e.g.: ruby project)"
  post_tags = STDIN.gets.chomp

  template = <<END
---
title: "#{post_name}"
published: #{post_date.strftime('%Y-%m-%d %H-%M-%S %:z')}
tags: #{post_tags}
---
END
  slug = "_posts/#{post_date.strftime('%Y-%m-%d')}-#{post_slug}.md"

  IO.write(slug, template)

  exec("$EDITOR #{slug}")
end
