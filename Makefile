help:
	@echo 'Makefile for a Hakyll site                                      '
	@echo '                                                                '
	@echo 'Usage:                                                          '
	@echo '    make compile        compile site.hs                         '
	@echo '    make build          (re)build the HTML at site_/            '
	@echo '    make clean          clean the site_/ directory              '
	@echo '    make preview        preview the site at http://0.0.0.0:8000/'
	@echo '    make deploy         deploy using rsync                      '
	@echo '                                                                '

compile:
	ghc --make site.hs

build:
	./site rebuild

clean:
	rm -rf _site _cache site site.hi

preview:
	./site preview

deploy: build
	rsync -avz _site/ nickcharlton.net:/var/www/site

.PHONY: help compile build clean preview deploy
