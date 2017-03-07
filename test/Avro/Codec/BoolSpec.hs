{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Avro.Codec.BoolSpec (spec) where

import Test.Hspec
import qualified Test.QuickCheck as Q

import           Data.List.NonEmpty (NonEmpty(..))
import           Data.Tagged
import           Data.Text
import qualified Data.ByteString.Lazy as BL

import           Data.Avro
import           Data.Avro.Schema
import qualified Data.Avro.Types as AT

{-# ANN module ("HLint: ignore Redundant do"        :: String) #-}

-- Avro definition for Bool

newtype OnlyBool = OnlyBool
  { onlyBoolValue :: Bool
  } deriving (Show, Eq)

onlyBoolSchema :: Schema
onlyBoolSchema =
  let fld nm = Field nm [] Nothing Nothing
   in Record "OnlyBool" (Just "test.contract") [] Nothing Nothing
        [ fld "onlyBoolValue" Boolean Nothing
        ]

instance ToAvro OnlyBool where
  toAvro sa = record onlyBoolSchema
    [ "onlyBoolValue" .= onlyBoolValue sa
    ]
  schema = pure onlyBoolSchema

instance FromAvro OnlyBool where
  fromAvro (AT.Record _ r) =
    OnlyBool <$> r .: "onlyBoolValue"

spec :: Spec
spec = describe "Avro.Codec.BoolSpec" $ do
  let x = untag (schema :: Tagged OnlyBool Type)
  it "should encode True correctly" $ do
    let trueEncoding = BL.singleton 0x01
    encode (OnlyBool True) `shouldBe` trueEncoding

  it "should encode False correctly" $ do
    let falseEncoding = BL.singleton 0x00
    encode (OnlyBool False) `shouldBe` falseEncoding

  it "should encode then decode True correctly" $ do
    decode x (encode $ OnlyBool True) `shouldBe` Success (OnlyBool True)

  it "should encode then decode False correctly" $ do
    decode x (encode $ OnlyBool False) `shouldBe` Success (OnlyBool False)
