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
replacePlaceholder toReplace expression =
  case expression of
    Placeholder -> Just toReplace

    ParentOf parent child   ->
      let mreplaced = replacePlaceholder toReplace child
          update updatedChild = return $ ParentOf parent updatedChild 
      in mreplaced >>= update

    BranchOf operator expressions  ->
      let seed = {found: false, res: []}

          -- | tries to replace in all children
          evaluateAllBranches currentExp seed = 
            case replacePlaceholder toReplace currentExp of
              Just replaced -> { found: true      , res: (  replaced:seed.res) }
              Nothing       -> { found: seed.found, res: (currentExp:seed.res) }

      in case foldr evaluateAllBranches seed expressions of
        {found = found, res = res}
          | found -> Just $ BranchOf operator expressions 
        otherwise -> Nothing

    otherwise -> Nothing
