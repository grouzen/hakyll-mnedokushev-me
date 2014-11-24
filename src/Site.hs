{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveDataTypeable #-}

module Main where

import Hakyll
import Data.Monoid (mconcat, (<>))

main :: IO ()
main = hakyllWith config $ do

  match "templates/*" $ compile templateCompiler
  
  match "pages/*" $ do
    route $ gsubRoute "pages/" (const "") `composeRoutes` setExtension "html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/default.html" defaultContext
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

  tags <- buildTags "posts/*" (fromCapture "tags/*.html")

  match "posts/*" $ do
    route $ setExtension "html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/post.html" (postCtx tags)
      >>= loadAndApplyTemplate "templates/default.html" defaultContext
      >>= relativizeUrls

  create ["posts.html"] $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll "posts/*"
      let ctx = constField "title" "Posts" <>
                listField "posts" (postCtx tags) (return posts) <>
                defaultContext
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
  --           defaultContext
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
            defaultContext

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
                defaultContext
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
