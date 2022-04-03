module HelVM.HelMS.Calculus.Parsers.ParserSpec (spec) where

import           HelVM.HelMS.Calculus.Parsers.FileUtil
import           HelVM.HelMS.Calculus.Parsers.Parser

import           HelVM.HelMS.Calculus.Reducers.AbstractionReducer
import           HelVM.HelMS.Calculus.Reducers.DefinedCombinatorReducer

import           HelVM.HelMS.Calculus.Lambda
import           HelVM.HelMS.Calculus.Reducer

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
    , "reverse"
    ] $ \name -> do
    it ("abstraction"  </> name) $ showP <$> parseFileSafe name `goldenShouldIO` buildAbsoluteAbstractionFileName "lc" name
    it ("combinator"   </> name) $ showP <$> (reduceAbstractions <$> parseFileSafe name) `goldenShouldIO` buildAbsoluteCombinatorFileName "lc" name
    it ("ski"          </> name) $ showP <$> (reduceDefinedCombinators . reduceAbstractions <$> parseFileSafe name) `goldenShouldIO` buildAbsoluteSkiFileName "lc" name

  describe "unit" $ forM_
    [ ("\\y.y(\\x.x)y\n"            , [Abs "y" (App (App (Var "y") (Abs "x" (Var "x"))) (Var "y"))])
    , ("\\ y . y (\\x . x) y\n"     , [Abs "y" (App (App (Var "y") (Abs "x" (Var "x"))) (Var "y"))])
    , (": false \\x . \\y . y\n"  , [Com "false" (Abs "x" (Abs "y" (Var "y")))])
    , (": false \\x . \\y . y\n: true  \\x . \\y . x\n"  , [Com "false" (Abs "x" (Abs "y" (Var "y"))),Com "true" (Abs "x" (Abs "y" (Var "x")))])
    , ("; false \\x . \\y . y\n: true  \\x . \\y . x\n"  , [Com "true" (Abs "x" (Abs "y" (Var "x")))])
    ] $ \(source , code) ->
    it (toString source) $ parseCalculus "<stdin>" source `shouldParse` code

parseFileSafe :: FilePath -> IO LambdaList
parseFileSafe filePath = safeIOToIO $ parseTextSafe filePath <$> readLangFile "lc" filePath

parseTextSafe :: FilePath -> Text -> Safe LambdaList
parseTextSafe filePath = liftEitherLegacy . first errorBundlePretty . parseCalculus filePath
