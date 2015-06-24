module Test.Main where

import Test.Unit
import Control.Monad.Eff

import Control.Monad.Error.Trans


import qualified Test.QuickParser as QCParse
import qualified Test.Parse as Parse
import qualified Test.Operations as Operations

main = do
  --QCParse.allProperties

  runTest do
    Operations.main
    Parse.main

  
    

