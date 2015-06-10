module Expresso.Operators where

import Data.Maybe
import Expresso.Parser.Data

expressionAnd :: ExpressoExpression -> ExpressoExpression -> ExpressoExpression
expressionAnd (BranchOf left) (BranchOf right)
  | left.operator == And && right.operator == And
  = BranchOf { operator: And, expressions: (left.expressions ++ right.expressions) }
expressionAnd (BranchOf left) right
  | left.operator == And
  = BranchOf { operator: And, expressions: (left.expressions ++ [right]) }
expressionAnd left (BranchOf right)
  | right.operator == And
  = BranchOf { operator: And, expressions: (left:right.expressions) }
expressionAnd left right
  = BranchOf { operator: And, expressions: [left,right] }


expressionOr :: ExpressoExpression -> ExpressoExpression -> ExpressoExpression
expressionOr (BranchOf left) (BranchOf right)
  | left.operator == Or && right.operator == Or
  = BranchOf { operator: Or, expressions: (left.expressions ++ right.expressions) }
expressionOr (BranchOf left) right
  | left.operator == Or
  = BranchOf { operator: Or, expressions: (left.expressions ++ [right]) }
expressionOr left (BranchOf right)
  | right.operator == Or
  = BranchOf { operator: Or, expressions: (left:right.expressions) }
expressionOr left right
  = BranchOf { operator: Or, expressions: [left,right] }

replacePlaceholder :: ExpressoExpression -> ExpressoExpression -> Maybe ExpressoExpression
replacePlaceholder replaceValue expressionWithPlaceholder = Nothing
