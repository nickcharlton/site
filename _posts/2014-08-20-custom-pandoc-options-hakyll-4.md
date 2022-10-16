---
title: Custom Pandoc Options with Hakyll 4
tags: pandoc hakyll haskell
---

[Pandoc][] has a huge set of extensions which are not enabled by default and
whilst [Hakyll][] does enable quite a few in its own options (like footnotes),
I wanted to add support for [definition lists][].

In Hakyll, the best way to do this seems to be to implement a custom content
compiler, as this can then be used everywhere you render content. This is
exactly what I did.

The first thing was to look up the reference to the [default compilers][] and
see what was already there. Hakyll provides:

* `pandocCompiler`
* `pandocCompilerWith`
* `pandocCompilerWithTransform`

The second of these allows you to pass in options (`ReaderOptions` and
`WriterOptions`) and is actually called by the first but with only the default
options. The [implementation of `pandocCompiler`][pandocCompilerImp] looks like:

```haskell
pandocCompiler :: Compiler (Item String)
pandocCompiler =
    pandocCompilerWith defaultHakyllReaderOptions defaultHakyllWriterOptions
```

Which gives us both the pattern to copy and the type declaration. The next
step is to add on custom options to the defaults. [Pandoc gives a list of the
options that can be passed to it in it's documentation][pandocOptions].

The `defaultHakyllWriterOptions` are [defined as a set][writerOptions], so
we'll need to add to that set and we'll also need to be able to access the
[Pandoc options][pandocOptions], so first import those:

```haskell
import qualified Data.Set as S
import           Text.Pandoc.Options
```

Then, we need to build up the custom compiler. That looks like this:

```haskell
customPandocCompiler :: Compiler (Item String)
customPandocCompiler =
    let customExtensions = [Ext_definition_lists]
        defaultExtensions = writerExtensions defaultHakyllWriterOptions
        newExtensions = foldr S.insert defaultExtensions customExtensions
        writerOptions = defaultHakyllWriterOptions {
                          writerExtensions = newExtensions
                        }
    in pandocCompilerWith defaultHakyllReaderOptions writerOptions
```

(To see it in place, you can see the [version in the repository][customCompiler].)

To walk through the compiler:

1. We set the list of extensions we wish to apply.
2. Compute the default set of extensions.
3. Insert our list of extensions into the set.
4. Initialise the writer options.
5. Pass that over to the `pandocCompilerWith` compiler.

Subsequently, we can use `customCompiler` everywhere we were previously using
`pandocCompiler`, and without having to repeat our options.

[Pandoc]: http://johnmacfarlane.net/pandoc/
[Hakyll]: http://jaspervdj.be/hakyll/
[definition lists]: http://johnmacfarlane.net/pandoc/README.html#definition-lists
[default compilers]: http://jaspervdj.be/hakyll/reference/Hakyll-Web-Pandoc.html#g:2
[pandocCompilerImp]: http://jaspervdj.be/hakyll/reference/src/Hakyll-Web-Pandoc.html#pandocCompiler
[pandocOptions]: http://hackage.haskell.org/package/pandoc-1.10.0.4/docs/Text-Pandoc-Options.html
[writerOptions]: http://jaspervdj.be/hakyll/reference/src/Hakyll-Web-Pandoc.html#defaultHakyllWriterOptions
[customCompiler]: https://github.com/nickcharlton/nickcharlton.net/blob/c6b5b417c36c3b425ea1074d5d41d00425d202a6/site.hs#L125
