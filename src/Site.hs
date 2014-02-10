{-# LANGUAGE OverloadedStrings #-}

module Main where

import Hakyll

main :: IO ()
main = hakyllWith config $ do

  match "templates/*" $ compile templateCompiler
  
  match "pages/*.md" $ do
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


config :: Configuration
config = defaultConfiguration {
  deployCommand = "rsync --checksum -ave 'ssh' _site/* root@mnedokushev.me:/var/www/"
  }
