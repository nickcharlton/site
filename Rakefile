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
  system("rsync -avzc _site/ nickcharlton.net:/var/www/site")
end
