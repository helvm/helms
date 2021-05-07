module HelVM.HelMS.Assemblers.Expectations (
  shouldBeDo,
  shouldParseReturn,
  goldenShouldBe,
  goldenShouldParse
) where

import HelVM.HelMS.Common.API

import Test.Hspec
import Test.Hspec.Attoparsec

infix 1 `shouldBeDo`
shouldBeDo :: (HasCallStack, Show a, Eq a) => a -> IO a -> Expectation
shouldBeDo action expected = shouldBe action =<< expected

infix 1 `shouldParseReturn`
shouldParseReturn :: (Show a, Eq a) => ParsedIO a -> a -> Expectation
shouldParseReturn action = shouldReturn (joinEitherToIO action)

infix 1 `goldenShouldBe`
goldenShouldBe :: (HasCallStack, Show a, Eq a) => IO a -> IO a -> Expectation
goldenShouldBe action expected = join $ liftA2 shouldBe action expected

infix 1 `goldenShouldParse`
goldenShouldParse :: (Show a, Eq a) => ParsedIO a -> IO a -> Expectation
goldenShouldParse action expected = join $ liftA2 shouldParse action expected

joinEitherToIO :: ParsedIO a -> IO a
joinEitherToIO io = eitherToIO =<< io

eitherToIO :: Parsed a -> IO a
eitherToIO (Right value)  = return value
eitherToIO (Left message) = fail message
