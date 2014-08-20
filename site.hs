{-# LANGUAGE OverloadedStrings #-}

import Data.Binary (Binary)
import Data.Typeable
import Data.Monoid (mappend, mconcat)
import qualified Data.Set as S
import Hakyll
import Text.Pandoc.Options

main :: IO ()
main = hakyllWith hakyllConfig $ do
    -- Static Assets and Resources
    let assets = ["css/*", "favicon.ico", "nickcharlton.pub", "images/*",
                  "resources/**", "fonts/**"]
    match (foldr1 (.||.) assets) $ do
        route idRoute
        compile copyFileCompiler

    -- Build Tags
    tags <- buildTags "posts/*" (fromCapture "tags/*.html")

    -- Render each and every post
    match "posts/*" $ do
        route $ setExtension "html"
        compile $ customPandocCompiler
            >>= saveSnapshot "content"
            >>= return . fmap demoteHeaders
            >>= loadAndApplyTemplate "templates/post.html" (postCtx tags)
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    -- Post Archives
    create ["archives.html"] $ do
        route idRoute
        compile $ do
            list <- postList tags "posts/*" recentFirst
            let ctx = constField "title" "Archives" `mappend`
                      constField "posts" list `mappend`
                      defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/list.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    -- Index
    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- fmap (take 5) . recentFirst =<< loadAllSnapshots "posts/*" "content"
            let indexCtx =
                    listField "posts" (postCtx tags) (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls

    -- Pages
    let pages = ["projects.md", "style-guide.md"]
    match (foldr1 (.||.) pages) $ do
        route $ setExtension "html"
        compile $ customPandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    -- Tags
    tagsRules tags $ \tag pattern -> do
        let title = "Tagged: " ++ tag

        route idRoute
        compile $ do
            list <- postList tags pattern recentFirst
            let ctx = constField "title" title `mappend`
                        constField "posts" list `mappend`
                        defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/list.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    -- Read templates
    match "templates/*" $ compile templateCompiler

    -- Render the 404 page, we don't relativize URL's here.
    match "404.html" $ do
        route idRoute
        compile $ customPandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    -- Render RSS feed
    create ["atom.xml"] $ do
        route idRoute
        compile $ do
            loadAllSnapshots "posts/*" "content"
                >>= fmap (take 10) . recentFirst
                >>= renderAtom (feedConfiguration "All Posts") feedCtx

postCtx :: Tags -> Context String
postCtx tags = mconcat
    [ dateField "date" "%B %e, %Y"
    , tagsField "tags" tags
    , defaultContext
    ]

feedCtx :: Context String
feedCtx = mconcat
    [ bodyField "description"
    , defaultContext
    ]

postList :: Tags -> Pattern -> ([Item String] -> Compiler [Item String])
         -> Compiler String
postList tags pattern preprocess' = do
    postItemTpl <- loadBody "templates/item.html"
    posts       <- preprocess' =<< loadAll pattern
    applyTemplateList postItemTpl (postCtx tags) posts

customPandocCompiler :: Compiler (Item String)
customPandocCompiler =
    let customExtensions = [Ext_definition_lists]
        defaultExtensions = writerExtensions defaultHakyllWriterOptions
        newExtensions = foldr S.insert defaultExtensions customExtensions
        writerOptions = defaultHakyllWriterOptions {
                          writerExtensions = newExtensions
                        }
    in pandocCompilerWith defaultHakyllReaderOptions writerOptions

feedConfiguration :: String -> FeedConfiguration
feedConfiguration title = FeedConfiguration
    { feedTitle       = "Nick Charlton"
    , feedDescription = "iOS, Mac and Ruby Developer. Amateur Chef."
    , feedAuthorName  = "Nick Charlton"
    , feedAuthorEmail = "nick@nickcharlton.net"
    , feedRoot        = "http://nickcharlton.net"
    }

hakyllConfig :: Configuration
hakyllConfig = defaultConfiguration
    { deployCommand   = "rsync -avzc _site/ nickcharlton.net:/var/www/site" }
