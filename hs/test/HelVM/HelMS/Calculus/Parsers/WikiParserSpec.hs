module HelVM.HelMS.Calculus.Parsers.WikiParserSpec (spec) where

import           HelVM.HelMS.Calculus.Parsers.WikiParser

import           HelVM.HelMS.Calculus.Lambda

import           Test.Hspec                              (Spec, it)

import           Test.Hspec.Megaparsec

spec :: Spec
spec = do
  it "λx.λy.y"          $ parseLineCalculus "" "λx.λy.y" `shouldParse` Abs "x" (Abs "y" (Var "y"))
  it "FALSE := λx.λy.y" $ parseLineCalculus "" "| FALSE := λx.λy.y" `shouldParse` Com "FALSE" (Abs "x" (Abs "y" (Var "y")))
