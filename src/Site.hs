{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveDataTypeable #-}

module Main where

import Hakyll
import Data.Monoid (mconcat, (<>))
import Control.Applicative ((<$>))
import Data.Char           (isSpace)
import Data.List           (dropWhileEnd)
import System.Process      (readProcess)
import Data.Time.Clock
import Data.Time.Calendar

main :: IO ()
main = hakyllWith config $ do
  
  let versionContext = generatedDateField "gdate" <> defaultContext
  
  match "templates/*" $ compile templateCompiler

  -- redirect from http://mnedokushev.me/github to my github profile
  -- match "redirects/*" $ do
  --   let redirectCtx = constField "redirecturl" "http://github.com/grouzen/" <> defaultContext
    
  --   route idRoute
  --   compile $ pandocCompiler
  --     >>= loadAndApplyTemplate "templates/redirect.html" redirectCtx
  
  match "pages/*" $ do
    route $ gsubRoute "pages/" (const "") `composeRoutes` setExtension "html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/default.html" versionContext
      >>= relativizeUrls

  match "css/*.css" $ do
    route idRoute
    compile compressCssCompiler

  match "css/i/*" $ do
    route idRoute
    compile copyFileCompiler

  match "images/*" $ do
    route idRoute
    compile copyFileCompiler
 
  match "files/*" $ do
    route idRoute
    compile copyFileCompiler
  
  match "files/papers/*" $ do
    route idRoute
    compile copyFileCompiler

  tags <- buildTags "posts/*" (fromCapture "tags/*.html")

  match "posts/*" $ do
    route $ setExtension "html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/post.html" (postCtx tags)
      >>= loadAndApplyTemplate "templates/default.html" versionContext
      >>= relativizeUrls

  create ["posts.html"] $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll "posts/*"
      let ctx = constField "title" "Posts" <>
                listField "posts" (postCtx tags) (return posts) <>
                versionContext
      makeItem ""
        -- >>= applyAsTemplate ctx
        >>= loadAndApplyTemplate "templates/posts.html" ctx
        >>= loadAndApplyTemplate "templates/default.html" ctx
        >>= relativizeUrls

  -- match "pages/*" $ do
  --   route $ gsubRoute "pages/" (const "") `composeRoutes` setExtension "html"
  --   compile $ do
  --     posts <- fmap (take 3) . recentFirst =<< loadAll "posts/*"
  --     let indexContext =
  --           listField "posts" (postCtx tags) (return posts) <>
  --           field "tags" (\_ -> renderTagList tags) <>
  --           versionContext
  --     pandocCompiler
  --       -- >>= applyAsTemplate indexContext
  --       >>= loadAndApplyTemplate "templates/default.html" indexContext
  --       >>= relativizeUrls

  match "index.html" $ do
    route idRoute
    compile $ do
      posts <- fmap (take 3) . recentFirst =<< loadAll "posts/*"
      let indexContext =
            listField "posts" (postCtx tags) (return posts) <>
            field "tags" (\_ -> renderTagList tags) <>
            versionContext

      getResourceBody
        >>= applyAsTemplate indexContext
        >>= loadAndApplyTemplate "templates/index.html" indexContext
        >>= relativizeUrls
    
  tagsRules tags $ \tag pattern -> do
    let title = "Posts tagged " ++ tag

    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll pattern
      let ctx = constField "title" title <>
                listField "posts" (postCtx tags) (return posts) <>
                versionContext
      makeItem ""
        >>= loadAndApplyTemplate "templates/posts.html" ctx
        >>= loadAndApplyTemplate "templates/default.html" ctx
        >>= relativizeUrls

  where
    pages =
      [
        "pages/contacts.md"
      ]

postCtx :: Tags -> Context String
postCtx tags = mconcat
    [ modificationTimeField "mtime" "%U"
    , dateField "date" "%B %e, %Y"
    , tagsField "tags" tags
    , defaultContext
    ]


config :: Configuration
config = defaultConfiguration {
  -- deploying into antoshka's raspberrypi
  deployCommand = "rsync --checksum -ave 'ssh -p 444' _site/* grouzen@idkfa.im:~/www" 
  }

-- -- Got this code from http://vapaus.org/text/hakyll-configuration.html
-- -- Actually it doesn't work well, I mean at all ;(
-- getGitVersion :: FilePath -> IO String
-- getGitVersion path = trim <$> readProcess "git" ["log", "-1", "--format=%h (%ai) %s", "--", path] ""
--   where
--     trim = dropWhileEnd isSpace

-- -- Field that contains the latest commit hash that hash touched the current item.
-- versionField :: String -> Context String
-- versionField name = field name $ \item -> unsafeCompiler $ do
--     let path = toFilePath $ itemIdentifier item
--     getGitVersion path

-- -- Field that contains the commit hash of HEAD.
-- headVersionField :: String -> Context String
-- headVersionField name = field name $ \_ -> unsafeCompiler $ getGitVersion ""

generatedDateField :: String -> Context String
generatedDateField name = field name $ \item -> unsafeCompiler $ do
  (year,month,day) <- getCurrentTime >>= return . toGregorian . utctDay
  return $ (show month) ++ "." ++ (show day) ++ "." ++ (show year)
