-- module Test.Operations where

-- import Data.Maybe
-- import Text.Parsing.Parser
-- import Test.Unit
-- import Debug.Trace

-- import Expresso.Operations
-- import Expresso.Parser.Data

-- main = runTest do
--   test "replace placeholder" do
--     let incoming = Placeholder
--         replacement = expression "Holden" (facetValue "Commodore")
    
--     assert "flat placeholder was not replaced" $
--       let result = replacePlaceholder replacement incoming
--       in case result of
--         Just r | r == replacement ->
--           false
--         otherwise ->
--           false
  
