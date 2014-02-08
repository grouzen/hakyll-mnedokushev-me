
module Main where

import Hakyll

main :: IO ()
main = hakyllWith config $ do

  match (fromGlob "templates/*") $ compile templateCompiler
  
  match (fromGlob "pages/*.md") $ do
    route $ gsubRoute "pages/" (const "") `composeRoutes` setExtension "html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate (fromFilePath "templates/default.html") defaultContext
      >>= relativizeUrls

  match (fromGlob "css/*.css") $ do
    route idRoute
    compile compressCssCompiler

  match (fromGlob "css/i/*") $ do
    route idRoute
    compile copyFileCompiler

  match (fromGlob "images/*") $ do
    route idRoute
    compile copyFileCompiler


config :: Configuration
config = defaultConfiguration {
  deployCommand = "rsync --checksum -ave 'ssh' _site/* root@mnedokushev.me:/var/www/"
  }
