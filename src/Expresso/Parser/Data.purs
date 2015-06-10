module Expresso.Parser.Data where

import Data.Array
import Data.Foldable

data BranchType = And | Or

type AspectAndFacet = { aspect :: String, facet :: Facet }

aspectAndFacet :: String -> Facet -> AspectAndFacet
aspectAndFacet a f = { aspect: a, facet: f }

data Facet = Value { literal :: String }
           | Keyword { keyword :: String }
           | Geolocation { geolocation :: String }

facetValue :: String -> Facet
facetValue l = Value { literal: l }

facetKeyword :: String -> Facet
facetKeyword k = Keyword { keyword: k }

facetGeolocation :: String -> Facet
facetGeolocation g = Geolocation { geolocation: g }


data ExpressoExpression = Expression { expression :: AspectAndFacet }
                        | ParentOf { parent :: AspectAndFacet, child :: ExpressoExpression }
                        | BranchOf { operator :: BranchType, expressions :: [ExpressoExpression] }

expression :: String -> Facet -> ExpressoExpression
expression a f = let anf = aspectAndFacet a f in Expression { expression: anf }

parentOf :: AspectAndFacet -> ExpressoExpression -> ExpressoExpression
parentOf anf e = ParentOf { parent: anf, child: e }

branchOf :: BranchType -> [ExpressoExpression] -> ExpressoExpression
branchOf type' expressions = BranchOf { operator: type', expressions: expressions } 

-- | Instances

instance branchTypeEq :: Eq BranchType where
  (==) And And = true
  (==) Or  Or  = true
  (==) _   _   = false

  (/=) a   b   = not (a == b)

instance branchTypeShow :: Show BranchType where
  show And = "And"
  show Or  = "Or"         

instance facetEq :: Eq Facet where
  (==) (Value {literal = a })          (Value {literal = b})           = a == b
  (==) (Keyword {keyword = a })        (Keyword {keyword = b})         = a == b
  (==) (Geolocation {geolocation = a}) (Geolocation {geolocation = b}) = a == b
  (==) _ _ = false

  (/=) a b = not (a == b)

instance facetShow :: Show Facet where
  show (Value { literal = a })           = a <> "."
  show (Keyword { keyword = a })         = "keyword(" <> a <> "."
  show (Geolocation { geolocation = a }) = "geolocation(" <> a <> ")."

instance expressionShow :: Show ExpressoExpression where
  show (Expression {expression = anf})                = showAnf anf
  show (ParentOf {parent = anf, child = exp})         = "(C." <> showAnf anf <> "(" <> show exp <> ")."
  show (BranchOf {operator = bt, expressions = exps}) = "(" <> show bt <> "." <> intercalate "_." (map show exps) <> ")"

showAnf :: AspectAndFacet -> String
showAnf {aspect = a, facet = f} = a <> "." <> show f
