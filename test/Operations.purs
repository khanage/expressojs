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
  branchFlattened

expressionReplaced =
  test "replace placeholder" do
    let placeholder = e"(<!>)"
        unreplacedExpression = e"Make.Holden."

    assertC "expression that wasn't a placeholder was modified" $
      unreplacedExpression `replacedWithIs` unreplacedExpression $ Nothing

    assertC "naked placeholder was not replaced" $
      placeholder `replacedWithIs` unreplacedExpression $ Just unreplacedExpression

parentReplaced =
  test "replace placeholder in parent expression" do
    let placeholderExpression = e"(C.Make.Holden._.(<!>))"
        replacement           = e"Model.Commodore."
        expected              = e"(C.Make.Holden._.Model.Commodore.)"

    assertC "placeholder value was not replaced" $
      placeholderExpression `replacedWithIs` replacement $ Just expected

    assertC "expression was changed when it shouldn't've been" $
      expected `replacedWithIs` replacement $ Nothing

branchReplaced =
  test "and branch expression" do
    let replacement = e"Model.Commodore."
        placeholder = e"(And.Make.Holden._.(<!>))"
        expected    = e"(And.Make.Holden._.Model.Commodore.)"

    assertC "placeholder wasn't replaced" $
      placeholder `replacedWithIs` replacement $ Just expected

    assertC "expression was modified when it shouldn't've been" $
      expected `replacedWithIs` replacement $ Nothing

branchFlattened =
  test "nested branch expressions" do
    let placeholderBranch = e"(And.Make.Holden._.(<!>))"

        nestedBranch      = e"(And.Model.Commodore._.Color.Black.)"
        flattenedBranch   = e"(And.Make.Holden._.Model.Commodore._.Color.Black.)"

        unnestedBranch    = e"(Or.Model.Commodore._.Color.Black.)"
        unflattenedBranch = e"(And.Make.Holden._.(Or.Model.Commodore._.Color.Black.))"

        additionalVals    = e"(And.Make.Holden._.Color.Black._.(<!>))"
        duplicatedBranch  = e"(And.Make.Holden._.Model.Commodore.)"
        dedupedBranch     = e"(And.Make.Holden._.Color.Black._.Model.Commodore.)"
 
    assertC "nested branch wasn't flattened" $
      placeholderBranch `replacedWithIs` nestedBranch $ Just flattenedBranch

    assertC "mismatched branch was flattened" $
      placeholderBranch `replacedWithIs` unnestedBranch $ Just unflattenedBranch

    assertC "duplicates in replaced branch were not flattened" $
      additionalVals `replacedWithIs` duplicatedBranch $ Just dedupedBranch    

replacedWithIs :: forall e.
                    ExpressoExpression
                 -> ExpressoExpression
                 -> Maybe ExpressoExpression
                 -> ContT Unit (Eff ( trace :: Trace | e)) Boolean
replacedWithIs incoming replacement Nothing =
  lift $ case replacePlaceholder incoming replacement of
    Nothing -> return true

    Just r -> do
      print ""
      print $ "Incoming expression was modified"
      print $ "Incoming: " <> show incoming
      print $ "Result:   " <> show r
      return false

replacedWithIs incoming replacement (Just expected) =
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

e incoming =
  case parseExpressoExpression incoming of
    Just exp -> exp
