module HelVM.HelMS.Calculus.Lexer where

import           HelVM.HelMS.Calculus.Value

import           Text.Megaparsec            hiding (many)
import           Text.Megaparsec.Char
import qualified Text.Megaparsec.Char.Lexer as L

identifierParser :: Parser Identifier
identifierParser = toIdentifier <$> lexeme (liftA2 (:) letterChar (many alphaNumChar))

stringLiteral :: Parser String
stringLiteral = char '\"' *> manyTill L.charLiteral (char '\"')

charLiteral :: Parser Char
charLiteral = between (char '\'') (char '\'') L.charLiteral

decimalParser :: Parser Integer
decimalParser = lexeme L.decimal

parens , braces , angles , brackets :: Parser a -> Parser a
parens    = between (symbol "(") (symbol ")")
braces    = between (symbol "{") (symbol "}")
angles    = between (symbol "<") (symbol ">")
brackets  = between (symbol "[") (symbol "]")

arrow , backslash , comma ,  colon , define , dot , equals , hash , lambda , semicolon , underscore , vertical :: Parser Text
arrow      = symbol "->"
backslash  = symbol "\\"
comma      = symbol ","
colon      = symbol ":"
define     = symbol ":="
dot        = symbol "."
equals     = symbol "="
hash       = symbol "#"
lambda     = symbol "λ"
semicolon  = symbol ";"
underscore = symbol "_"
vertical   = symbol "|"

-- | White space

lexeme :: Parser a -> Parser a
lexeme = L.lexeme sc

symbol :: Text -> Parser Text
symbol = L.symbol sc

sc :: Parser ()
sc = L.space hspace1 (L.skipLineComment ";") (L.skipBlockCommentNested "#|" "|#")

-- | Types

parseAll :: Parser a -> FilePath -> Text -> Parsed a
parseAll parser = parse (parser <* eof)

type Parser = Parsec Void Text

type Parsed = Either (ParseErrorBundle Text Void)
