{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Main where

import Views
import Model

import Web.Scotty
import Web.Scotty.Internal.Types (ActionT)
import Network.Wai.Middleware.Static
import Network.Wai.Middleware.RequestLogger (logStdout)
import Network.Wai.Middleware.Cors
import Control.Monad.IO.Class
import qualified Data.Configurator as C
import qualified Data.Configurator.Types as C
import Data.Pool(createPool)
import qualified Data.Text.Lazy as TL
import Data.Aeson
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.Migration
import qualified Data.ByteString.Char8 as BS8

-- Parse file "application.conf" and get the DB connection info
makeModelConfig :: C.Config -> IO (Maybe Model.ModelConfig)
makeModelConfig conf = do
    host <- C.lookup conf "database.host" :: IO (Maybe String)
    name <- C.lookup conf "database.name" :: IO (Maybe String)
    user <- C.lookup conf "database.user" :: IO (Maybe String)
    password <- C.lookup conf "database.password" :: IO (Maybe String)
    return $ ModelConfig <$> host
                         <*> name
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

            let url = "host=" ++ (dbHost conf) ++ " dbname=" ++ (dbName conf) ++ " user=" ++ (dbUser conf) ++ " password=" ++ (dbPassword conf)
            let cmd = MigrationCommands [ MigrationInitialization, MigrationDirectory "postgresql" ]
            let ctx = MigrationContext cmd False

            con <- connectPostgreSQL (BS8.pack url)
            _ <- withTransaction con (runMigration (ctx con))

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
                    local_id <- param "id" :: ActionM TL.Text
                    maybeImage <- liftIO $ findImage pool local_id
                    viewImage maybeImage


                -- DELETE
                delete "/admin/image/:id" $ do
                    local_id <- param "id" :: ActionM TL.Text
                    deleteImage pool local_id
                    deletedImage local_id

-- Parse the request body into the Image
getImageParam :: ActionT TL.Text IO (Maybe Image)
getImageParam = do
    b <- body
    return $ (decode b :: Maybe Image)
