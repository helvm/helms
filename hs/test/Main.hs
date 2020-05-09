module Main where

import qualified Spec
import           Test.Hspec      (hspec)
import           Test.Hspec.Slow

main :: IO ()
main = do
  config <- configure 1
  hspec $ timeThese config Spec.spec
