{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Main where

import Views
import Model

import Web.Scotty
import Web.Scotty.Internal.Types (ActionT)
import Network.Wai
import Network.Wai.Middleware.Static
import Network.Wai.Middleware.RequestLogger (logStdoutDev, logStdout)
import Network.Wai.Middleware.HttpAuth
import Network.Wai.Middleware.Cors
import Control.Applicative
import Control.Monad.IO.Class
import qualified Data.Configurator as C
import qualified Data.Configurator.Types as C
import Data.Pool(Pool, createPool, withResource)
import qualified Data.Text.Lazy as TL
import Data.Aeson
import Database.PostgreSQL.Simple

-- Parse file "application.conf" and get the DB connection info
makeModelConfig :: C.Config -> IO (Maybe Model.ModelConfig)
makeModelConfig conf = do
    name <- C.lookup conf "database.name" :: IO (Maybe String)
    user <- C.lookup conf "database.user" :: IO (Maybe String)
    password <- C.lookup conf "database.password" :: IO (Maybe String)
    return $ ModelConfig <$> name
                         <*> user
                         <*> password

main :: IO ()
main = do
    loadedConf <- C.load [C.Required "application.conf"]
    dbConf <- makeModelConfig loadedConf

    case dbConf of
        Nothing -> putStrLn "No database configuration found, exiting..."
        Just conf -> do
            pool <-  createPool (newConn conf) close 1 40 10

            putStrLn "Starting Server..."
            scotty 3000 $ do
                middleware simpleCors
                middleware $ staticPolicy (noDots >-> addBase "static")
                middleware $ logStdout

                -- LIST
                get "/images" $ do
                    images <- liftIO $ listImages pool
                    imagesList images

                -- CREATE
                post "/admin/images" $ do
                    image <- getImageParam
                    insertImage pool image
                    createdImage image

                -- UPDATE
                put "/admin/images" $ do
                    image <- getImageParam
                    updateImage pool image
                    updatedImage image

                -- VIEW
                get "/image/:id" $ do
                    id <- param "id" :: ActionM TL.Text
                    maybeImage <- liftIO $ findImage pool id
                    viewImage maybeImage


                -- DELETE
                delete "/admin/image/:id" $ do
                    id <- param "id" :: ActionM TL.Text
                    deleteImage pool id
                    deletedImage id

-- Parse the request body into the Image
getImageParam :: ActionT TL.Text IO (Maybe Image)
getImageParam = do
    b <- body
    return $ (decode b :: Maybe Image)
    where makeImage s = ""
