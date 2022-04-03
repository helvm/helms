module HelVM.HelMS.Calculus.Parsers.WikiParser (
  parseCalculus,
  parseLineCalculus,
) where

import           HelVM.HelMS.Calculus.Lambda
import           HelVM.HelMS.Calculus.Lexer

import           Text.Megaparsec             hiding (many, some)
import           Text.Megaparsec.Char

parseCalculus :: FilePath -> Text -> Parsed LambdaList
parseCalculus = parseAll (removeNop <$> some lambdaLnParser)

removeNop :: LambdaList -> LambdaList
removeNop = filter (/= Nop)

parseLineCalculus :: FilePath -> Text -> Parsed Lambda
parseLineCalculus = parseAll lambdaLnParser

lambdaLnParser :: Parser Lambda
lambdaLnParser = sc *> lambdaParser <* some newline

lambdaParser :: Parser Lambda
lambdaParser = defineCombinatorParser <|> functionParser <|> applicationParser

defineCombinatorParser :: Parser Lambda
defineCombinatorParser = liftA2 Com ((hash *> identifierParser <* define) <?> "define combinator") lambdaParser

functionParser :: Parser Lambda
functionParser = liftA2 Abs ((lambda *> (identifierParser <|> underscore) <* dot) <?> "function") lambdaParser

applicationParser :: Parser Lambda
applicationParser = foldl0 App Nop <$> many terminalParser

terminalParser :: Parser Lambda
terminalParser = variableParser <|> parens lambdaParser

variableParser :: Parser Lambda
variableParser = Var <$> (identifierParser <|> (show <$> decimalParser)) <?> "variable"

-- | Util
foldl0 :: (a -> a -> a) -> a -> [a] -> a
foldl0 _ d      [] = d
foldl0 f _ (h : t) = foldl' f h t
