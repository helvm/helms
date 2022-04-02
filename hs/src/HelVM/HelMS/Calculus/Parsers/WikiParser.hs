module HelVM.HelMS.Calculus.Parsers.WikiParser (
  parseCalculus,
  parseLineCalculus,
) where

import           HelVM.HelMS.Calculus.Lambda
import           HelVM.HelMS.Calculus.Lexer

import           Data.Foldable

import           Text.Megaparsec             hiding (many, some)
import           Text.Megaparsec.Char

parseCalculus :: FilePath -> Text -> Parsed LambdaList
parseCalculus = parseAll (some lambdaParser <* space1)

parseLineCalculus :: FilePath -> Text -> Parsed Lambda
parseLineCalculus = parseAll lambdaParser

lambdaParser :: Parser Lambda
lambdaParser = defineCombinatorParser <|> functionParser <|> applicationParser

defineCombinatorParser :: Parser Lambda
defineCombinatorParser = liftA2 Com ((hash *> identifierParser <* define) <?> "define combinator") lambdaParser

functionParser :: Parser Lambda
functionParser = liftA2 Abs ((lambda *> identifierParser <* dot) <?> "function") lambdaParser

applicationParser :: Parser Lambda
applicationParser = foldl1 App <$> many terminalParser

terminalParser :: Parser Lambda
terminalParser = variableParser <|> parens lambdaParser

variableParser :: Parser Lambda
variableParser = Var <$> identifierParser <?> "variable"
