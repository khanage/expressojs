module Expresso.Parser where

import Data.Array
import Data.Either
import Data.Monoid
import Data.Foldable
import Data.Maybe
    
import Control.Alt
import Control.Monad.Eff

import Text.Parsing.Parser
import Text.Parsing.Parser.String
import Text.Parsing.Parser.Combinators

import Debug.Trace

import Expresso.Parser.Data

-- | Porcelein

parseExpressoExpression :: String -> Maybe ExpressoExpression
parseExpressoExpression incoming =
    case runParser incoming expressoParser of
      Left err -> Nothing
      Right p  -> Just p

-- | Implementation
                  
type ExpressoParser a = Parser String a

delimiter :: String
delimiter = "."

combinationsSep :: String
combinationsSep = "_."

ident :: ExpressoParser String
ident = char `many1Till` dot |>> flatten
  where dot = string delimiter

branchAnd :: ExpressoParser BranchType
branchAnd = string "And." >>% And
branchOr :: ExpressoParser BranchType
branchOr  = string "Or."  >>% Or
branch :: ExpressoParser BranchType
branch = branchAnd <|> branchOr

facet :: ExpressoParser Facet
facet = choice [ keyword, geolocation, flatValue ]
        where flatValue = ident |>> facetValue
              
              keyword = betweenS "keyword(" ")" do
                str <- manyFlattened (satisfy ((/=) ")"))
                return $ facetKeyword str

              geolocation = betweenS "geolocation(" ")" do
                str <- manyFlattened (satisfy ((/=) ")"))
                return $ facetGeolocation str

placeholderP :: ExpressoParser ExpressoExpression
placeholderP = do
  string "<!>."
  return Placeholder

expressionP :: ExpressoParser ExpressoExpression
expressionP = do
  aspect <- ident
  facet  <- facet
  return $ expression aspect facet

expressoParser :: ExpressoParser ExpressoExpression
expressoParser = choice [ branchParser, hierarchicalParser, placeholderP, expressionP ]

-- Won't compile if this is in the outer scope
  where hierarchicalParser = betweenS "(C." ")" $ do
          parentAspect <- ident
          parentValue <- ident |>> facetValue

          let parent = aspectAndFacet parentAspect parentValue
          
          string combinationsSep
          child <- expressoParser
          return $ parentOf parent child
          
        branchParser = try $ betweenS "(" ")" do
          btype <- branch
          
          head <- expressoParser
          
          tail <- manyTill
                  (do string combinationsSep
                      expressoParser)
                  (lookAhead $ string ")")
          
          return $ branchOf btype (head:tail)  


                 
-- | Combinators
(|>>) :: forall f a b. (Functor f) => f a -> (a -> b) -> f b
(|>>) = flip (<$>)

(.>>) :: forall s a m b. (Monad m) => ParserT s m a -> ParserT s m b -> ParserT s m a
(.>>) pa pb = do
  a <- pa
  pb
  return a

betweenS :: forall m a. (Monad m) => String -> String -> ParserT String m a -> ParserT String m a
betweenS start end inner = between (string start) (string end) inner

(>>%) :: forall s a m b. (Monad m) => ParserT s m a -> b -> ParserT s m b
(>>%) p v = p >>= \_ -> return v

flatten :: forall m. (Monoid m) => [m] -> m
flatten ms = foldr (<>) mempty ms

many' :: forall m s a. (Monad m) => ParserT s m a -> ParserT s m [a]
many' p = do
  a <- p
  (do as <- many' p
      return (a:as)) <|> return [a]

manyFlattened :: forall m s a. (Monoid a, Monad m) => ParserT s m a -> ParserT s m a
manyFlattened  p = many' p |>> flatten
