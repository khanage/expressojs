module Expresso.Operations where

import Data.Maybe
import Data.Foldable
import Expresso.Parser.Data
import Optic.Core

type ExpressionMerge = ExpressoExpression -> ExpressoExpression -> ExpressoExpression
    
expressionBuilder :: BranchType -> ExpressionMerge
expressionBuilder op (BranchOf opl left) (BranchOf opr right)
  | opl == op && opr == op
  = BranchOf op (left ++ right) 
expressionBuilder op (BranchOf opl left) right
  | opl == op
  = BranchOf op (left ++ [right]) 
expressionBuilder op left (BranchOf opr right)
  | opr == op
  = BranchOf op (left:right) 
expressionBuilder op left right
  = BranchOf op [left,right] 

expressionAnd :: ExpressionMerge
expressionAnd = expressionBuilder And

expressionOr :: ExpressionMerge
expressionOr = expressionBuilder Or

replacePlaceholder :: ExpressoExpression -> ExpressoExpression -> Maybe ExpressoExpression
replacePlaceholder expression toReplace =
  case expression of
    Placeholder -> Just toReplace

    ParentOf parent child ->
      let mreplaced = replacePlaceholder child toReplace
          update updatedChild = return $ ParentOf parent updatedChild 
      in mreplaced >>= update

    BranchOf operator expressions ->
      let evaluateAllBranches currentExp seed = 
            case replacePlaceholder currentExp toReplace of
              Just replaced -> { found: true      , res: (  replaced:seed.res) }
              Nothing       -> { found: seed.found, res: (currentExp:seed.res) }

      in case foldr evaluateAllBranches {found: false, res: []} expressions of
        {found = foundInEval, res = modifiedResults}
          | foundInEval -> Just $ BranchOf operator modifiedResults
        otherwise -> Nothing

    otherwise -> Nothing
