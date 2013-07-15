{-# LANGUAGE OverloadedStrings #-}

import Data.Binary (Binary)
import Data.Typeable
import Data.Monoid (mappend, mconcat)
import Hakyll

main :: IO ()
main = hakyllWith hakyllConfig $ do
    -- Compile and Compress Styles
    match "css/*.scss" $ do
        route $ setExtension "css"
        compile sassCompiler

    -- Static Assets and Resources
    let assets = ["fonts/*", "css/*", "favicon.ico", 
                    "apple-touch-icon-precomposed.png", "resources/**"]

    match (foldr1 (.||.) assets) $ do
        route idRoute
        compile copyFileCompiler

    -- Build Tags
    tags <- buildTags "posts/*" (fromCapture "tags/*.html")

    -- Render each and every post
    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= saveSnapshot "content"
            >>= return . fmap demoteHeaders
            >>= loadAndApplyTemplate "templates/post.html" (postCtx tags)
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    -- Render each and every link post
    match "links/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= saveSnapshot "links"
            >>= return . fmap demoteHeaders
            >>= loadAndApplyTemplate "templates/link.html" linkCtx
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

    -- Link Archives
    create ["links.html"] $ do
        route idRoute
        compile $ do
            list <- linkList "links/*" recentFirst
            let ctx = constField "title" "Links" `mappend`
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
            posts <- fmap (take 5) . recentFirst =<< contentList
            let indexCtx =
                    listField "posts" (postCtx tags) (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls

    -- Pages
    let pages = ["about.md", "projects.md", "projects/*"]

    match (foldr1 (.||.) pages) $ do
        route $ setExtension "html"
        compile $ pandocCompiler
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
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    -- Render RSS feed
    create ["atom.xml"] $ do
        route idRoute
        compile $ do
            contentList
                >>= fmap (take 10) . recentFirst
                >>= renderAtom (feedConfiguration "All Posts") feedCtx

postCtx :: Tags -> Context String
postCtx tags = mconcat
    [ dateField "date" "%B %e, %Y"
    , tagsField "tags" tags
    , defaultContext
    ]

linkCtx :: Context String
linkCtx = mconcat
    [ dateField "date" "%B %e, %Y"
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

linkList :: Pattern -> ([Item String] -> Compiler [Item String])
         -> Compiler String
linkList pattern preprocess' = do
    linkItemTpl <- loadBody "templates/item.html"
    links       <- preprocess' =<< loadAll pattern
    applyTemplateList linkItemTpl linkCtx links

contentList :: (Binary a, Typeable a) => Compiler [Item a]
contentList = do
    a <- loadAllSnapshots "posts/*" "content"
    b <- loadAllSnapshots "links/*" "links"
    return (a ++ b)

sassCompiler :: Compiler (Item String)
sassCompiler =
    getResourceString
        >>= withItemBody (unixFilter "sass" ["-s", "--scss"])
        >>= return . fmap compressCss

feedConfiguration :: String -> FeedConfiguration
feedConfiguration title = FeedConfiguration
    { feedTitle       = "nickcharlton.net"
    , feedDescription = "iOS, Robotics, Python, 3D printing, and other thoughts."
    , feedAuthorName  = "Nick Charlton"
    , feedAuthorEmail = "hello@nickcharlton.net"
    , feedRoot        = "http://nickcharlton.net"
    }

hakyllConfig :: Configuration
hakyllConfig = defaultConfiguration
    { deployCommand   = "rsync -avzc _site/ nickcharlton.net:/var/www/site" }
