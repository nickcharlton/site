# The Source of nickcharlton.net

A thing of many decendants, this version is implemented using
[Hakyll](http://jaspervdj.be/hakyll/index.html), a static site generator written 
in Haskell. Previous versions have been implemented in Sinatra, Jekyll, Wordpress 
and countless others.

## Usage

Setup Haskell, `cabal install hakyll`, then:

    git clone git://github.com/nickcharlton/nickcharlton.net.git
    cd nickcharlton.net
    ghc --make site.hs
    ./site preview
    open http://localhost:8000/

Static site generators are notoriously hard to get working without other
examples (especially when you already have a way of doing things.) So please
use it as an example (but, have some taste about my design…)

## License

The code is licensed under MIT and the content under 
[Creative Commons Attribution-Non-Commercial-Share Alike](http://creativecommons.org/licenses/by-nc-sa/2.0/uk/").
However; if you would like to use it outside of this, just give me a shout.

