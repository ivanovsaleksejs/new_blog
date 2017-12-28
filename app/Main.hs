{-# language OverloadedStrings #-}
{-# language DuplicateRecordFields #-}
module Main where

import SitePipe
import qualified Text.Mustache as MT
import qualified Text.Mustache.Types as MT
import qualified Data.Text as T

main :: IO ()
main = siteWithGlobals templateFuncs $ do

    posts <- resourceLoader markdownReader ["posts/*.md"]
    let
        tags = getTags makeTagUrl posts

        indexContext :: Value
        indexContext = object [ "posts" .= posts
                        , "tags" .= tags
                        , "url" .= ("/index.html" :: String)
                        ]

    writeTemplate "templates/index.html" [indexContext]
    writeTemplate "templates/post.html" posts
    staticAssets

templateFuncs :: MT.Value
templateFuncs = MT.object [ "tagUrl" MT.~> MT.overText (T.pack . makeTagUrl . T.unpack) ]

makeTagUrl :: String -> String
makeTagUrl tagName = "/tags/" ++ tagName ++ ".html"

staticAssets :: SiteM ()
staticAssets = copyFiles
    [ "css/*.css"
    , "js/"
    , "images/"
    ]
