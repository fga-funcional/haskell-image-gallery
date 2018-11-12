{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Views where

import Model

import Web.Scotty
import qualified Data.Text.Lazy as TL

imagesList :: [Image] -> ActionM ()
imagesList images = json images

viewImage :: Maybe Image -> ActionM ()
viewImage Nothing = json ()
viewImage (Just image) = json image

createdImage :: Maybe Image -> ActionM ()
createdImage _ = json ()

updatedImage :: Maybe Image -> ActionM ()
updatedImage _ = json ()

deletedImage :: TL.Text -> ActionM ()
deletedImage _ = json ()
