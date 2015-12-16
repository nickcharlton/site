#!/bin/sh

echo "Cleaning and then building..."

bundle exec jekyll clean
bundle exec jekyll build

echo "Running Rsync..."
rsync -avzc _site/ nickcharlton.net:/var/www/site
