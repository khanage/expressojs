module Test.Main where

import Data.Maybe
import Data.Either
import Data.Array

import Expresso.Parser
import Expresso.Parser.Data

import Control.Monad.Eff

import Text.Parsing.Parser

import Test.Unit

import Debug.Trace

main = runTest do
  test "simple test" do
    assert "'Key.Value.' parses" $ didParse expressoParser "Key.Value."
    assertFalse "'' parses" $ didParse expressoParser ""

  test "simple facet" do
    let input = "Key.Value."
    assertParsed "'Key.Value.' parses to facet expression" input
      \done parse -> done true

    assertParsed "'Key.Value.' parses to facet expression" input
      \done parse -> case parse of
        Expression exp -> done $ exp.aspect == "Key" 
                              && exp.facet  == Value "Value" 
        otherwise -> done false

  test "keyword facet" do
    let input = "Key.keyword(hello)."
        expected = expression "Key" (Keyword "hello")
        inFmt s = "'" <> input <> "' " <> s

    assertParsed (inFmt "didn't parse") input
      \done parse -> done true

  test "parent facet" do
    let input = "(C.Key.Value._.Child.V.)"
        inFmt s = "'" <> input <> "' "  <> s
        expected = ParentOf {aspect: "Key", facet: Value "Value" }
                   (Expression {aspect: "Child", facet: Value "V" })

    assertParsed (inFmt "didn't parse to " <> show expected) input
      \done parse -> case parse of
        ParentOf p cs -> done true
        otherwise -> do
          print otherwise
          done false

    assertParsed (inFmt "parent is not Key Value") input
      \done parse -> case parse of
        (ParentOf exp child) -> done $ exp.aspect == "Key"
                                    && exp.facet  == Value "Value"
        otherwise -> done false

    assertParsed (inFmt "child is not Child V") input
      \done parse -> case parse of
        ParentOf _ (Expression child)
          -> done $ child.aspect == "Child"
                 && child.facet  == Value "V"
        otherwise -> done false

  test "and branch facet" do
    let input = "(And.K1.V1._.K2.V2.)"
        inFmt s = "'" <> input <> "' " <> s

    assertParsed (inFmt "didn't parse to And") input
      \done parse -> case parse of
        BranchOf And _ -> done true
        otherwise -> done false

    assertParsed (inFmt "doesn't create two values") input
      \done parse -> case parse of
        BranchOf And bs -> done $ length bs == 2
        otherwise -> done false

    assertParsed (inFmt "doesn't parse first value") input
      \done parse -> case parse of
        BranchOf _ (Expression { aspect = "K1", facet =  (Value "V1") }:_) -> done true
        otherwise -> done false

    assertParsed (inFmt "doesn't parse second value") input
      \done parse -> case parse of
        BranchOf _ (_:Expression { aspect = "K2", facet =  (Value "V2") }:[]) -> done true
        otherwise -> done false

  test "or branch facet" do
    let input = "(Or.K1.V1._.K2.V2.)"
        inFmt s = "'" <> input <> "' " <> s

    assertParsed (inFmt "didn't parse to Or") input
      \done parse -> case parse of
        BranchOf Or _ -> done true
        otherwise -> done false

    assertParsed (inFmt "doesn't create two values") input
      \done parse -> case parse of
        BranchOf Or bs -> done $ length bs == 2
        otherwise -> done false

    assertParsed (inFmt "doesn't parse first value") input
      \done parse -> case parse of
        BranchOf _ (Expression { aspect = "K1", facet =  (Value "V1") }:_) -> done true
        otherwise -> done false

    assertParsed (inFmt "doesn't parse second value") input
      \done parse -> case parse of
        BranchOf _ (_:Expression { aspect = "K2", facet =  (Value "V2") }:[]) -> done true
        otherwise -> done false

  test "complex query" do
    let input = "(And.(Or.K1.V1._.K2.V2.)_.K3.V3.)"
        inFmt s = "'" <> input <> "' " <> s

    assertParsed (inFmt "didn't parse") input
      \done parse -> done true

    assertParsed (inFmt "didn't match first and") input
      \done parse -> case parse of
        BranchOf And _ -> done true
        otherwise -> done false

    assertParsed (inFmt "didn't match nested or") input
      \done parse -> case parse of
        BranchOf And ((BranchOf Or _):_) -> done true
        otherwise -> done false

didParse :: forall a. ExpressoParser a -> String -> Boolean
didParse parser input = case runParser input parser of
  Left _ -> false
  Right _ -> true

assertParsedWith :: forall e. ExpressoParser ExpressoExpression
                 -> String
                 -- ^ message to use for asserting
                 -> String
                 -- ^ incoming data
                 -> ( (Boolean -> Eff (trace :: Trace | e) Unit) 
                      -> ExpressoExpression 
                      -> Eff (trace :: Trace | e) Unit )
                 -- ^ call back to match on
                 -> Assertion (trace :: Trace | e)
assertParsedWith parser message incoming parsedResultCallback =
  assertFn message \done -> case runParser incoming parser of
    Right x -> parsedResultCallback done x
    Left x -> do
      print $ "Error parsing " <> show x
      done false

assertParsed = assertParsedWith expressoParser
