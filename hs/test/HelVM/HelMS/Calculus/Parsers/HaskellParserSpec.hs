module HelVM.HelMS.Calculus.Parsers.HaskellParserSpec (spec) where

import           HelVM.HelMS.Calculus.Parsers.FileUtil
import           HelVM.HelMS.Calculus.Parsers.HaskellParser

import           HelVM.HelMS.Calculus.Reducers.AbstractionReducer
import           HelVM.HelMS.Calculus.Reducers.DefinedCombinatorReducer

import           HelVM.HelMS.Calculus.Reducer

import           HelVM.HelMS.Calculus.Lambda

import           HelVM.Common.Control.Safe
import           HelVM.Common.Util

import           HelVM.GoldenExpectations

import           System.FilePath.Posix

import           Test.Hspec                                             (Spec, describe, it)
import           Test.Hspec.Megaparsec
import           Text.Megaparsec

spec :: Spec
spec = describe "parseCalculus" $ do
--describe "assembly" $ forM_


  describe "parse" $ forM_
    [ "false"
    , "mult"
    , "logic"
    , "relude"
    , "prelude"
    , "reverse"
    ] $ \name -> do
    it ("abstraction"  </> name) $ showP <$> parseFileSafe name `goldenShouldIO` buildAbsoluteHlcAbstractionFileName name
    it ("combinator"   </> name) $ showP <$> (reduceAbstractions <$> parseFileSafe name) `goldenShouldIO` buildAbsoluteHlcCombinatorFileName name
    it ("ski"          </> name) $ showP <$> (reduceDefinedCombinators . reduceAbstractions <$> parseFileSafe name) `goldenShouldIO` buildAbsoluteHlcSkiFileName name

  describe "unit" $ forM_
    [ ("\\y->y(\\x->x)y\n"            , [Abs "y" (App (App (Var "y") (Abs "x" (Var "x"))) (Var "y"))])
    , ("\\ y -> y (\\x -> x) y\n"     , [Abs "y" (App (App (Var "y") (Abs "x" (Var "x"))) (Var "y"))])
    , ("# false = \\x -> \\y -> y\n"  , [Com "false" (Abs "x" (Abs "y" (Var "y")))])
    , ("# false = \\x -> \\y -> y\n# true  = \\x -> \\y -> x\n"  , [Com "false" (Abs "x" (Abs "y" (Var "y"))),Com "true" (Abs "x" (Abs "y" (Var "x")))])
    , ("; false = \\x -> \\y -> y\n# true  = \\x -> \\y -> x\n"  , [Com "true" (Abs "x" (Abs "y" (Var "x")))])
    ] $ \(source , code) ->
    it (toString source) $ parseCalculus "<stdin>" source `shouldParse` code







parseFileSafe :: FilePath -> IO LambdaList
parseFileSafe filePath = safeIOToIO $ parseTextSafe filePath <$> readHlcFile filePath

parseTextSafe :: FilePath -> Text -> Safe LambdaList
parseTextSafe filePath = liftEitherLegacy . first errorBundlePretty . parseCalculus filePath
