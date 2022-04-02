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
--  describe "golden" $ forM_
--    [ "prelude"
--    ] $ \name -> do
--    it ("abstraction"  </> name) $ showP <$> parseFileSafe name `goldenShouldIO` buildAbsoluteHlcAbstractionFileName name
--    it ("combinator"   </> name) $ showP <$> (reduceAbstractions <$> parseFileSafe name) `goldenShouldIO` buildAbsoluteHlcCombinatorFileName name
--    it ("ski"          </> name) $ showP <$> (reduceDefinedCombinators . reduceAbstractions <$> parseFileSafe name) `goldenShouldIO` buildAbsoluteHlcSkiFileName name

  describe "unit" $ do
    it "λx.λy.y"            $ parseLineCalculus "" "λx.λy.y" `shouldParse` Abs "x" (Abs "y" (Var "y"))
    it "# FALSE := λx.λy.y" $ parseLineCalculus "" "# FALSE := λx.λy.y" `shouldParse` Com "FALSE" (Abs "x" (Abs "y" (Var "y")))

parseFileSafe :: FilePath -> IO LambdaList
parseFileSafe filePath = safeIOToIO $ parseTextSafe filePath <$> readHlcFile filePath

parseTextSafe :: FilePath -> Text -> Safe LambdaList
parseTextSafe filePath = liftEitherLegacy . first errorBundlePretty . parseCalculus filePath
