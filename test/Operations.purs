module Test.Operations where

import Control.Monad.Cont.Trans
import Control.Monad.Trans
import Control.Monad.Eff
import Data.Maybe
import Text.Parsing.Parser
import Test.Unit
import Debug.Trace

import Expresso.Parser
import Expresso.Operations
import Expresso.Parser.Data

main = do
  -- Unit tests
  expressionReplaced
  parentReplaced
  branchReplaced

expressionReplaced =
  test "replace placeholder" do
    let placeholder = Placeholder
        unreplacedExpression = expression "Make" $ facetValue "Holden"

    assertC "expression that wasn't a placeholder was modified" $
      expressionBecame unreplacedExpression unreplacedExpression $ Nothing

    assertC "naked placeholder was not replaced" $
      expressionBecame placeholder unreplacedExpression $ Just unreplacedExpression

parentReplaced =
  test "replace placeholder in parent expression" do
    let parentExpression c = parentOf (aspectAndFacet "Make" $ facetValue "Holden") c
        placeholderExpression = parentExpression Placeholder
        replacement = expression "Model" $ facetValue "Commodore"
        expected = parentExpression replacement

    assertC "placeholder value was not replaced" $
      expressionBecame placeholderExpression replacement $ Just expected

    assertC "expression was changed when it shouldn't've been" $
      expressionBecame expected replacement Nothing

branchReplaced =
  test "and expression" do
    let branchWith e = branchOf And [expression "Make" (facetValue "Holden"), e]
        replacement = expression "Model" $ facetValue "Commodore"
        placeholder = branchWith Placeholder
        expected = branchWith replacement

    assertC "placeholder wasn't replaced" $
      expressionBecame placeholder replacement $ Just expected

    assertC "expression was modified when it shouldn't've been" $
      expressionBecame expected replacement Nothing

expressionBecame :: forall e.
                    ExpressoExpression
                 -> ExpressoExpression
                 -> Maybe ExpressoExpression
                 -> ContT Unit (Eff ( trace :: Trace | e)) Boolean
expressionBecame incoming replacement Nothing =
  lift $ case replacePlaceholder incoming replacement of
    Nothing -> return true

    Just r -> do
      print ""
      print $ "Incoming expression was modified"
      print $ "Incoming: " <> show incoming
      print $ "Result:   " <> show r
      return false

expressionBecame incoming replacement (Just expected) =
  lift $ case replacePlaceholder incoming replacement of
    Just r | r == expected -> return true

    Just r -> do
      print ""
      print $ "Incoming was modified, but not as expected"
      print $ "Incoming: " <> show incoming
      print $ "Expected: " <> show expected
      print $ "Result:   " <> show r
      return false

    otherwise -> do
      print ""
      print $ "No replacement was made, when one was expected"
      print $ "Incoming: " <> show incoming
      print $ "Expected: " <> show expected
      return false
