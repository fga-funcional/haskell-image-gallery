{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Model where

import GHC.Generics (Generic)
import GHC.Int
import Web.Scotty.Internal.Types (ActionT)
import Data.Text.Lazy
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Lazy.Encoding as TL
import qualified Data.ByteString.Lazy.Char8 as BL
import Control.Monad.IO.Class
import Database.PostgreSQL.Simple
import Data.Pool(Pool, withResource)
import Data.Aeson(FromJSON, ToJSON)

data Image = Image
  { id          :: Integer
  , title       :: !Text
  , description :: !Text
  , src         :: !Text
} deriving (Show, Generic)

instance ToJSON Image
instance FromJSON Image

data ModelConfig = ModelConfig {
     dbName :: String,
     dbUser :: String,
     dbPassword :: String
} deriving (Show, Generic)


newConn :: ModelConfig -> IO Connection
newConn conf = connect defaultConnectInfo
                       { connectUser = dbUser conf
                       , connectPassword = dbPassword conf
                       , connectDatabase = dbName conf
                       }

--------------------------------------------------------------------------------
-- Utilities for interacting with the DB.
-- No transactions.
--
-- Accepts arguments
fetch :: (FromRow r, ToRow q) => Pool Connection -> q -> Query -> IO [r]
fetch pool args sql = withResource pool retrieve
      where retrieve conn = query conn sql args

-- No arguments -- just pure sql
fetchSimple :: FromRow r => Pool Connection -> Query -> IO [r]
fetchSimple pool sql = withResource pool retrieve
       where retrieve conn = query_ conn sql

-- Update database
execSql :: ToRow q => Pool Connection -> q -> Query -> IO Int64
execSql pool args sql = withResource pool ins
       where ins conn = execute conn sql args


-------------------------------------------------------------------------------
-- Utilities for interacting with the DB.
-- Transactions.
--
-- Accepts arguments
fetchT :: (FromRow r, ToRow q) => Pool Connection -> q -> Query -> IO [r]
fetchT pool args sql = withResource pool retrieve
      where retrieve conn = withTransaction conn $ query conn sql args

-- No arguments -- just pure sql
fetchSimpleT :: FromRow r => Pool Connection -> Query -> IO [r]
fetchSimpleT pool sql = withResource pool retrieve
       where retrieve conn = withTransaction conn $ query_ conn sql

-- Update database
execSqlT :: ToRow q => Pool Connection -> q -> Query -> IO Int64
execSqlT pool args sql = withResource pool ins
       where ins conn = withTransaction conn $ execute conn sql args

--------------------------------------------------------------------------------

listImages :: Pool Connection -> IO [Image]
listImages pool = do
     res <- fetchSimple pool "SELECT * FROM image ORDER BY id DESC" :: IO [(Integer, TL.Text, TL.Text, TL.Text)]
     return $ Prelude.map (\(local_id, local_title, local_description, local_src) -> Image local_id local_title local_description local_src) res

findImage :: Pool Connection -> TL.Text -> IO (Maybe Image)
findImage pool param_id = do
     res <- fetch pool (Only param_id) "SELECT * FROM image WHERE id=?" :: IO [(Integer, TL.Text, TL.Text, TL.Text)]
     return $ oneImage res
     where oneImage ((local_id, local_title, local_description, local_src) : _) = Just $ Image local_id local_title local_description local_src
           oneImage _ = Nothing


insertImage :: Pool Connection -> Maybe Image -> ActionT TL.Text IO ()
insertImage _ Nothing = return ()
insertImage pool (Just (Image _ local_title local_description local_src)) = do
     _ <- liftIO $ execSqlT pool [local_title, local_description, local_src]
                            "INSERT INTO image(title, description, src) VALUES(?,?,?)"
     return ()

updateImage :: Pool Connection -> Maybe Image -> ActionT TL.Text IO ()
updateImage _ Nothing = return ()
updateImage pool (Just (Image local_id local_title local_description local_src)) = do
     _ <- liftIO $ execSqlT pool [local_title, local_description, local_src, (TL.decodeUtf8 $ BL.pack $ show local_id)]
                            "UPDATE image SET title=?, description=?, src=? WHERE id=?"
     return ()

deleteImage :: Pool Connection -> TL.Text -> ActionT TL.Text IO ()
deleteImage pool local_id = do
     _ <- liftIO $ execSqlT pool [local_id] "DELETE FROM image WHERE id=?"
     return ()
