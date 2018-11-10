{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Main where

import Web.Scotty
import GHC.Generics
import Data.Aeson (FromJSON, ToJSON)
import Network.Wai.Middleware.Cors

instance ToJSON Image
instance FromJSON Image

data Image = Image
  { title :: String
  , description :: String
  , src :: String
} deriving (Show, Generic)


images =
  [  Image "Abobora" "Find some fibonacci numbers" "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSoG4PCwHlqcA7c6HQP2ijopEnf1G2_AZ9pYSuft3SCVlZrovZS"
    , Image "Abobora" "Find some fibonacci numbers" "https://diy.sndimg.com/content/dam/images/diy/fullset/2007/9/26/0/MrHappypumpkin.jpg.rend.hgtvcom.966.725.suffix/1420761586663.jpeg"
    , Image "Abobora" "Find some fibonacci numbers" "https://digitalspyuk.cdnds.net/16/43/480x483/gallery-1477647170-monsters-inc-pumpkin.jpg"
  ]

main :: IO ()
main = do
  putStrLn "Starting Server..."
  scotty 3000 $ do

    middleware simpleCors

    get "/" $ do
      text "Ola mundo!!"


    get "/images" $ do
      json images
