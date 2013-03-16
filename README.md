# The Source of nickcharlton.net

A thing of many decendants, this version is implemented using [Hakyll][], a static 
site generator written in Haskell. Previous versions have been implemented in 
Sinatra, Jekyll, Wordpress and countless others.

## Usage

Setup Haskell, `cabal install hakyll`, then:

```bash
git clone git://github.com/nickcharlton/nickcharlton.net.git
cd nickcharlton.net
ghc --make site.hs
./site preview
open http://localhost:8000/
```

Static site generators are notoriously hard to get working without other
examples (especially when you already have a way of doing things.) So please
use it as an example (but, have some taste about my design…)

## License

The code is licensed under MIT and the content under [CC BY-NC-SA 2.0 UK][]. I am, 
however, open to other things, just ask.

The icons (which are web fonts) are from [Symbolset][] which are Copyright 2013 
Oak Studios LLC. You can't reuse them without a license. You can view this license
alongside the fonts.

[Hakyll]: http://jaspervdj.be/hakyll/
[CC BY-NC-SA 2.0 UK]: http://creativecommons.org/licenses/by-nc-sa/2.0/uk/
[Symbolset]: http://symbolset.com/

