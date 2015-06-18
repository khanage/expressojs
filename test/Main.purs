module Test.Main where

import Test.Unit

import qualified Test.Parse as Parse
import qualified Test.Operations as Operations

main = runTest do
  Operations.main
  Parse.main
