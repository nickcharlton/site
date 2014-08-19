# nickcharlton.net

This is the source of [nickcharlton.net]. It's existed for many years, but the
current version is implemented using [Hakyll][] 4, a static site generator
written in Haskell. Previous versions have been implemented in Sinatra,
Jekyll, Wordpress and countless others.

## Usage

Setup Haskell, `cabal install hakyll`, then:

```bash
git clone git://github.com/nickcharlton/nickcharlton.net.git
cd nickcharlton.net
ghc --make site.hs
./site rebuild
./site watch
```

Static site generators can be a bit of a pain to get working with from nothing,
so feel free to use this as an example to base your implementation off of.

## License

The code is licensed under MIT and the content under [CC BY-NC-SA 2.0 UK][].
I am, however, open to other things, just ask.

[Hakyll]: http://jaspervdj.be/hakyll/
[CC BY-NC-SA 2.0 UK]: http://creativecommons.org/licenses/by-nc-sa/2.0/uk/
