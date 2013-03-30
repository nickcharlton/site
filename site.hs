{-# LANGUAGE OverloadedStrings, Arrows #-}
module Main where

import Prelude hiding (id)
import Control.Category (id)
import Control.Monad (forM_)
import Control.Arrow (arr, (>>>), (***), second)
import Data.Monoid (mempty, mconcat)
import qualified Data.Map as M
import Data.List (sortBy)
import Data.Ord (comparing)
import Data.List (reverse)

import Hakyll

-- | Entry point
--
main :: IO ()
main = hakyllWith config $ do
    -- Compile {less}
    match "css/main.less" $ do
        route   $ setExtension ".css"
        -- lessc can't read from stdin         
        compile $ getResourceString >>> unixFilter "lessc" ["css/main.less"]

    -- Compress CSS
    match "css/*.css" $ do
        route idRoute
        compile compressCssCompiler

    -- Copy Fonts
    match "fonts/*" $ do
        route idRoute
        compile copyFileCompiler

    -- Resources
    match "resources/**" $ do
        route idRoute
        compile copyFileCompiler

    -- Render each and every post
    match "posts/*" $ do
        route   $ setExtension ".html"
        compile $ pageCompiler
            --- store the post contents before we render the template
            >>> arr (copyBodyToField "description")
            >>> arr (renderDateField "date" "%B %e, %Y" "Date unknown")
            >>> renderTagsField "prettytags" (fromCapture "tags/*")
            >>> applyTemplateCompiler "templates/post.html"
            --- now it has the template, and we use it for the index
            >>> arr (copyBodyToField "full")
            >>> applyTemplateCompiler "templates/default.html"
            >>> relativizeUrlsCompiler

    -- Render each and every link post
    match "links/*" $ do
        route   $ setExtension ".html"
        compile $ pageCompiler
            --- store the post contents before we render the template
            >>> arr (copyBodyToField "description")
            >>> arr (renderDateField "date" "%B %e, %Y" "Date unknown")
            >>> applyTemplateCompiler "templates/link.html"
            --- now it has the template, and we use it for the index
            >>> arr (copyBodyToField "full")
            >>> applyTemplateCompiler "templates/default.html"
            >>> relativizeUrlsCompiler

    -- Post Archives
    match "archives.html" $ route idRoute 
    create "archives.html" $ constA mempty
        >>> arr (setField "title" "Archives")
        >>> setFieldPageList myChronological
                "templates/post_item.html" "posts" "posts/*"
        >>> arr applySelf
        >>> applyTemplateCompiler "templates/posts.html"
        >>> applyTemplateCompiler "templates/default.html"
        >>> relativizeUrlsCompiler

    -- Link Archives
    match "links.html" $ route idRoute
    create "links.html" $ constA mempty
        >>> arr (setField "title" "Links")
        >>> setFieldPageList myChronological
                "templates/post_item.html" "posts" "links/*"
        >>> arr applySelf
        >>> applyTemplateCompiler "templates/posts.html"
        >>> applyTemplateCompiler "templates/default.html"
        >>> relativizeUrlsCompiler

    -- Index
    match "index.html" $ do
        route idRoute
        compile $ readPageCompiler
            >>> arr (setField "title" "Home")
            >>> requireA "tags" (setFieldA "tags" (renderTagList'))
            >>> setFieldPageList (take 3 . myChronological)
                    "templates/post_full.html" "posts" (regex "^(posts|links)/")
            >>> arr (copyBodyToField "description")
            >>> arr applySelf
            >>> applyTemplateCompiler "templates/default.html"
            >>> relativizeUrlsCompiler

    -- Pages
    forM_ pages $ \p ->
        match p $ do
            route   $ setExtension ".html"
            compile $ pageCompiler
                >>> applyTemplateCompiler "templates/default.html"
                >>> relativizeUrlsCompiler

    -- Tags
    create "tags" $
        requireAll "posts/*" (\_ ps -> readTags ps :: Tags String)

    -- Add a tag list compiler for every tag
    match "tags/*" $ route $ setExtension ".html"
    metaCompile $ require_ "tags"
        >>> arr tagsMap
        >>> arr (map (\(t, p) -> (tagIdentifier t, makeTagList t p)))

    -- Read templates
    match "templates/*" $ compile templateCompiler

    -- Render the 404 page, we don't relativize URL's here.
    match "404.html" $ do
        route idRoute
        compile $ pageCompiler
            >>> applyTemplateCompiler "templates/default.html"

    -- Render RSS feed
    match "atom.xml" $ route idRoute
    create "atom.xml" $ 
        requireAll_ "posts/*" 
            >>> arr (myChronological)
            >>> renderAtom feedConfiguration

    -- End
    return ()
  where
    renderTagList' :: Compiler (Tags String) String
    renderTagList' = renderTagList tagIdentifier

    tagIdentifier :: String -> Identifier (Page String)
    tagIdentifier = fromCapture "tags/*"

    pages = ["about.md", "projects.md"]

makeTagList :: String
            -> [Page String]
            -> Compiler () (Page String)
makeTagList tag posts =
    constA posts
        >>> pageListCompiler recentFirst "templates/post_item.html"
        >>> arr (copyBodyToField "posts" . fromBody)
        >>> arr (setField "title" ("Articles tagged with " ++ tag))
        >>> applyTemplateCompiler "templates/posts.html"
        >>> applyTemplateCompiler "templates/default.html"
        >>> relativizeUrlsCompiler

myChronological :: [Page a] -> [Page a]
myChronological = reverse . (sortBy $ comparing $ getField "published")

config :: HakyllConfiguration
config = defaultHakyllConfiguration

feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration
    { feedTitle       = "nickcharlton.net"
    , feedDescription = "iOS, Robotics, Python, 3D printing, and other thoughts."
    , feedAuthorName  = "Nick Charlton"
    , feedAuthorEmail = "hello@nickcharlton.net"
    , feedRoot        = "http://nickcharlton.net"
    }
