module Test.Main where

import Test.Unit
import Control.Monad.Eff

import qualified Test.QuickParser as QCParse
import qualified Test.Parse as Parse
import qualified Test.Operations as Operations

main = do
  -- QuickChecks
  --QCParse.allProperties

  -- Unit tests
  runTest do
    Operations.main
    Parse.main
