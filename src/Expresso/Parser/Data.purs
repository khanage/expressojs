module Expresso.Parser.Data where

import Data.Array
import Data.Foldable

data BranchType = And | Or

type AspectAndFacet = { aspect :: String, facet :: Facet }

aspectAndFacet :: String -> Facet -> AspectAndFacet
aspectAndFacet a f = { aspect: a, facet: f }

data Facet = Value String 
           | Keyword String 
           | Geolocation String 

facetValue :: String -> Facet
facetValue l = Value l 

facetKeyword :: String -> Facet
facetKeyword k = Keyword k 

facetGeolocation :: String -> Facet
facetGeolocation g = Geolocation g 


data ExpressoExpression = Placeholder
                        | Expression AspectAndFacet 
                        | ParentOf AspectAndFacet ExpressoExpression 
                        | BranchOf BranchType [ExpressoExpression] 

expression :: String -> Facet -> ExpressoExpression
expression a f = let anf = aspectAndFacet a f in Expression anf 

parentOf :: AspectAndFacet -> ExpressoExpression -> ExpressoExpression
parentOf anf e = ParentOf anf e 

branchOf :: BranchType -> [ExpressoExpression] -> ExpressoExpression
branchOf type' expressions = BranchOf type' expressions  

-- | Instances

instance branchTypeEq :: Eq BranchType where
  (==) And And = true
  (==) Or  Or  = true
  (==) _   _   = false

  (/=) a   b   = not (a == b)

instance facetEq :: Eq Facet where
  (==) (Value a)       (Value b)       = a == b
  (==) (Keyword a)     (Keyword b)     = a == b
  (==) (Geolocation a) (Geolocation b) = a == b
  (==) _ _ = false

  (/=) a b = not (a == b)

instance expressionEq :: Eq ExpressoExpression where
  (==) Placeholder          Placeholder          = true
  (==) (Expression anfl)    (Expression anfr)    = anfl `eqAnf` anfr
  (==) (ParentOf anfl expl) (ParentOf anfr expr) = anfl `eqAnf` anfr && expl == expr
  (==) (BranchOf btl expsl) (BranchOf btr expsr) = btl == btr && expsl == expsr
  (==) _ _ = false

  (/=) l r = not (l == r)

eqAnf :: AspectAndFacet -> AspectAndFacet -> Boolean
eqAnf ({ aspect = leftAspect, facet = leftFacet }) ({ aspect = rightAspect, facet = rightFacet})
    = leftAspect == rightAspect && leftFacet == rightFacet

-- | Show instances
instance branchTypeShow :: Show BranchType where
  show And = "And"
  show Or  = "Or"         

instance facetShow :: Show Facet where
  show (Value a)       = a
  show (Keyword a)     = "keyword(" <> a <> ")"
  show (Geolocation a) = "location(" <> a <> ")"

instance expressionShow :: Show ExpressoExpression where
  show Placeholder        = "(<!>)"
  show (Expression anf)   = showAnf anf
  show (ParentOf anf exp) = "(C." <> showAnf anf <> "_." <> show exp <> ")"
  show (BranchOf bt exps) = "(" <> show bt <> "." <> intercalate "_." (map show exps) <> ")"

showAnf :: AspectAndFacet -> String
showAnf {aspect = a, facet = f} = a <> "." <> show f <> "."
