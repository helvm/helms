module HelVM.HelMS.Calculus.Parsers.WikiParserSpec (spec) where

import           HelVM.HelMS.Calculus.Parsers.FileUtil
import           HelVM.HelMS.Calculus.Parsers.WikiParser

import           HelVM.HelMS.Calculus.Reducers.AbstractionReducer
import           HelVM.HelMS.Calculus.Reducers.DefinedCombinatorReducer

import           HelVM.HelMS.Calculus.Lambda

import           HelVM.Common.Control.Safe
import           HelVM.Common.Util

import           HelVM.GoldenExpectations

import           System.FilePath.Posix

import           Test.Hspec                                             (Spec, describe, it)
import           Test.Hspec.Megaparsec
import           Text.Megaparsec

spec :: Spec
spec = describe "parse" $ do
  describe "golden" $ forM_
    [ "prelude"
    ] $ \name -> do
    it ("abstraction"  </> name) $ showP <$> parseFileSafe name `goldenShouldIO` buildAbsoluteAbstractionFileName "wlc" name
    it ("combinator"   </> name) $ showP <$> (reduceAbstractions <$> parseFileSafe name) `goldenShouldIO` buildAbsoluteCombinatorFileName "wlc" name
    it ("ski"          </> name) $ showP <$> (reduceDefinedCombinators . reduceAbstractions <$> parseFileSafe name) `goldenShouldIO` buildAbsoluteSkiFileName "wlc" name

  describe "unit2" $ forM_
    [ ("λy.y(λx.x)y\n"            , [Abs "y" (App (App (Var "y") (Abs "x" (Var "x"))) (Var "y"))])
    , ("λ y . y (λx . x) y\n"     , [Abs "y" (App (App (Var "y") (Abs "x" (Var "x"))) (Var "y"))])
    , ("# false := λx . λy . y\n"  , [Com "false" (Abs "x" (Abs "y" (Var "y")))])
    , ("# false := λx . λy . y\n# true  := λx . λy . x\n"  , [Com "false" (Abs "x" (Abs "y" (Var "y"))),Com "true" (Abs "x" (Abs "y" (Var "x")))])
    , ("; false := λx . λy . y\n# true  := λx . λy . x\n"  , [Com "true" (Abs "x" (Abs "y" (Var "x")))])
    ] $ \(source , code) ->
    it (toString source) $ parseCalculus "<stdin>" source `shouldParse` code

  describe "unit" $ do
    it "λx.λy.y\n"            $ parseLineCalculus "" "λx.λy.y\n" `shouldParse` Abs "x" (Abs "y" (Var "y"))
    it "# FALSE := λx.λy.y\n" $ parseLineCalculus "" "# FALSE := λx.λy.y\n" `shouldParse` Com "FALSE" (Abs "x" (Abs "y" (Var "y")))

parseFileSafe :: FilePath -> IO LambdaList
parseFileSafe filePath = safeIOToIO $ parseTextSafe filePath <$> readLangFile "wlc" filePath

parseTextSafe :: FilePath -> Text -> Safe LambdaList
parseTextSafe filePath = liftEitherLegacy . first errorBundlePretty . parseCalculus filePath
