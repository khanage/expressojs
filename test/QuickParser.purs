module Test.QuickParser where

import Data.Char
import Data.Maybe
import Control.Monad.Trans
import Test.StrongCheck
import Test.StrongCheck.Gen
import Data.String (null, indexOf, fromCharArray, toCharArray, fromChar)
import Data.List.Lazy (take, filter, repeat, toArray)

import Expresso.Parser
import Expresso.Parser.Data

prop_parse_idempotent :: ExpressoExpression -> Result
prop_parse_idempotent incoming =
  case parseExpressoExpression (show incoming) of
    Just p    -> p === incoming
    otherwise -> Failed $ "Failed to parse {" <> show incoming <> "}!"

arbExpressoString :: Gen String
arbExpressoString = do
  s <- runAlphaNumString <$> arbitrary
  if null s then return "a" else return s

instance arbitraryFacet :: Arbitrary Facet where
  arbitrary = oneOf (Value <$> arbExpressoString)
                    [ Keyword <$> arbExpressoString
                    , Geolocation <$> arbExpressoString]

instance arbitraryBranchType :: Arbitrary BranchType where
  arbitrary = oneOf (pure And) [pure Or]

instance arbitraryExpression :: Arbitrary ExpressoExpression where
  arbitrary = oneOf branch [parent, expression, placeholder]
    where arbAnf = aspectAndFacet <$> arbExpressoString <*> arbitrary
          branch = do
            op <- arbitrary
            firstChild  <- oneOf expression [parent, placeholder]
            secondChild <- oneOf expression [parent, placeholder]
            children    <- arbitrary
            return $ BranchOf op (firstChild:secondChild:children)
          parent = do
            anf <- arbAnf
            child <- arbitrary
            return $ ParentOf anf child
          expression = do
            anf <- arbAnf
            return $ Expression anf
          placeholder = pure Placeholder
  
allProperties = do
 quickCheck prop_parse_idempotent
