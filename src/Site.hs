
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
      

config :: Configuration
config = defaultConfiguration
