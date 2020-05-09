module HelVM.HelMS.Schemer where


--import           Control.Monad.Error
--import           Data.Char                     (toLower)
--import           Data.Complex                  (Complex (..))
--import           Data.Ratio                    (Rational (..), (%))
--
--import           Numeric                       (readHex, readOct)
--import           Text.ParserCombinators.Parsec (ParseError, Parser, char, digit, endBy, letter, many1, noneOf, oneOf, parse, sepBy, skipMany1, space, string,
--                                                try)
--
--import           GHC.Arr
--
--import           System.IO                     hiding (getLine, hFlush, putStr, putStrLn, readFile, stderr, stdin, stdout)
--
--import           Relude.Unsafe                 (read, (!!))
--
--import           Data.List                     (foldl1, lookup)



--import qualified Text.Show
--
--import qualified Relude.Unsafe                 as Unsafe
--
--
--data LispVal = Atom String
--             | List [LispVal]
--             | DottedList [LispVal] LispVal
--             | Number Integer
--             | Ratio Rational
--             | Float Double
--             | Complex (Complex Double)
--             | String String
--             | Char Char
--             | Bool Bool
--             | Vector (Array Int LispVal)
--             | PrimitiveFunc ([LispVal] -> ThrowsError LispVal)
--             | Func { params  :: [String]
--                    , vararg  :: Maybe String
--                    , body    :: [LispVal]
--                    , closure :: Env
--                    }
--             | IOFunc ([LispVal] -> IOThrowsError LispVal)
--             | Port Handle
--
--instance Show LispVal where show = showVal
--
--data LispError = NumArgs Integer [LispVal]
--               | ExpectCondClauses
--               | ExpectCaseClauses
--               | TypeMismatch String LispVal
--               | Parser ParseError
--               | BadSpecialForm String LispVal
--               | NotFunction String String
--               | UnboundVar String String
--               | Default String
--
--instance Show LispError where show = showError
--
--instance Error LispError where
--    noMsg = Default "An error has occurred"
--    strMsg = Default
--
--type ThrowsError = Either LispError
--type Env = IORef [(String, IORef LispVal)]
--type IOThrowsError = ErrorT LispError IO
--
--data Unpacker = forall a. Eq a => AnyUnpacker (LispVal -> ThrowsError a)
--
--readOrThrow :: Parser a -> String -> ThrowsError a
--readOrThrow parser input = case parse parser "lisp" input of
--    Left err  -> throwError $ Parser err
--    Right val -> pure val
--
----readExpr :: String -> ThrowsError LispVal
--readExpr = readOrThrow parseExpr
--readExprList = readOrThrow (endBy parseExpr spaces)
--
--runOne :: [String ] -> IO ()
--runOne args = do
--    env <- primitiveBindings >>= flip bindVars [("args", List (String <$> drop 1 args))]
--    runIOThrows (show <$> eval env (List [Atom "load", String (args !! 0)])) >>= hPutStrLn stderr
--
--runRepl :: IO ()
--runRepl = primitiveBindings >>= until_ (== "quit") (readPrompt "Lisp>>> ") . evalAndPrint
--
----
---- LispVal Parsers
----
--
--parseExpr :: Parser LispVal
--parseExpr = parseAtom
--          <|> parseString
--          <|> try parseChar
--          <|> try parseComplex
--          <|> try parseFloat
--          <|> try parseRatio
--          <|> try parseNumber
--          <|> parseBool
--          <|> parseQuoted
--          <|> parseQuasiquote
--          <|> try parseUnquoteSplicing
--          <|> parseUnquote
--          <|> parseList
--
--parseAtom :: Parser LispVal
--parseAtom = do first <- letter <|> symbol
--               rest <- many (letter <|> digit <|> symbol)
--               (pure . Atom) (first:rest)
--
--parseList :: Parser LispVal
--parseList = char '(' *> parseList1
--
--parseList1 :: Parser LispVal
--parseList1 = (char ')' $> List [])
--               <|> do expr <- parseExpr
--                      parseList2 [expr]
--
--parseList2 :: [LispVal] -> Parser LispVal
--parseList2 expr = (char ')' $> List (reverse expr))
--                    <|> (spaces *> parseList3 expr)
--
--parseList3 :: [LispVal] -> Parser LispVal
--parseList3 expr = do char '.' *> spaces
--                     dotted <- parseExpr
--                     char ')'
--                     pure $ DottedList expr dotted
--                  <|> do next <- parseExpr
--                         parseList2 (next:expr)
--
--parseQuoted :: Parser LispVal
--parseQuoted = do char '\''
--                 x <- parseExpr
--                 pure $ List [Atom "quote", x]
--
--parseNumber :: Parser LispVal
--parseNumber = parsePlainNumber <|> parseRadixNumber
--
--parsePlainNumber :: Parser LispVal
--parsePlainNumber = many1 digit <&> (Number . read)
--
--parseRadixNumber :: Parser LispVal
--parseRadixNumber = char '#' *>
--                   (
--                        parseDecimal
--                        <|> parseBinary
--                        <|> parseOctal
--                        <|> parseHex
--                   )
--
--parseDecimal :: Parser LispVal
--parseDecimal = do char 'd'
--                  n <- many1 digit
--                  (pure . Number . read) n
--
--parseBinary :: Parser LispVal
--parseBinary = do char 'b'
--                 n <- many $ oneOf "01"
--                 (pure . Number . bin2int) n
--
--parseOctal :: Parser LispVal
--parseOctal = do char 'o'
--                n <- many $ oneOf "01234567"
--                (pure . Number . readWith readOct) n
--
--parseHex :: Parser LispVal
--parseHex = do char 'x'
--              n <- many $ oneOf "0123456789abcdefABCDEF"
--              (pure . Number . readWith readHex) n
--
--parseRatio :: Parser LispVal
--parseRatio = do num <- read <$> many1 digit
--                char '/'
--                denom <- read <$> many1 digit
--                (pure . Ratio) (num % denom)
--
--parseFloat :: Parser LispVal
--parseFloat = do whole <- many1 digit
--                char '.'
--                decimal <- many1 digit
--                pure $ Float (read (whole<>"."<>decimal))
--
--parseComplex :: Parser LispVal
--parseComplex = do r <- fmap toDouble (try parseFloat <|> parsePlainNumber)
--                  char '+'
--                  i <- fmap toDouble (try parseFloat <|> parsePlainNumber)
--                  char 'i'
--                  (pure . Complex) (r :+ i)
--               where toDouble (Float x)  = x
--                     toDouble (Number x) = fromIntegral x
--
--parseString :: Parser LispVal
--parseString = do char '"'
--                 s <- many (escapedChars <|> noneOf ['\\', '"'])
--                 char '"'
--                 (pure . String) s
--
--parseChar :: Parser LispVal
--parseChar = do string "#\\"
--               s <- many1 letter
--               pure $ case fmap toLower s of
--                      "space"   -> Char ' '
--                      "newline" -> Char '\n'
--                      [x]       -> Char x
--
--parseBool :: Parser LispVal
--parseBool = do char '#'
--               c <- oneOf "tf"
--               pure $ case c of
--                      't' -> Bool True
--                      'f' -> Bool False
--
--parseQuasiquote :: Parser LispVal
--parseQuasiquote = do char '`'
--                     expr <- parseExpr
--                     pure $ List [Atom "quasiquote", expr]
--
---- Bug: this allows the unquote to appear outside of a quasiquoted list
--parseUnquote :: Parser LispVal
--parseUnquote = do char ','
--                  expr <- parseExpr
--                  pure $ List [Atom "unquote", expr]
--
---- Bug: this allows unquote-splicing to appear outside of a quasiquoted list
--parseUnquoteSplicing :: Parser LispVal
--parseUnquoteSplicing = do string ",@"
--                          expr <- parseExpr
--                          pure $ List [Atom "unquote-splicing", expr]
--
--parseVector :: Parser LispVal
--parseVector = do string "#("
--                 elems <- sepBy parseExpr spaces
--                 char ')'
--                 pure $ Vector (listArray (0, length elems - 1) elems)
--
----
---- Show functions
----
--
--showVal :: LispVal -> String
--showVal (String s) = "\"" <> s <> "\""
--showVal (Atom name) = name
--showVal (Number n) = show n
--showVal (Bool True) = "#t"
--showVal (Bool False) = "#f"
--showVal (List xs) = "(" <> unwordsList xs <> ")"
--showVal (DottedList head tail) = "(" <> unwordsList head <> " . " <> showVal tail <> ")"
--showVal (Char c) = ['\'', c, '\'']
--showVal (PrimitiveFunc _) = "<primitive>"
--
--showVal (Func {params=args, vararg=varargs, body=body, closure=env}) =
--    "(lambda (" <> toString (unwords (show <$> args)) <>
--      (case varargs of
--            Nothing  -> ""
--            Just arg -> " . " <> arg) <> ") ...)"
--
--showVal (Port _) = "<IO port>"
--showVal (IOFunc _) = "<IO primitive>"
--
--showError :: LispError -> String
--showError ExpectCondClauses = "Expect at least 1 true cond clause"
--showError ExpectCaseClauses = "Expect at least 1 true case clause"
--showError (UnboundVar msg varname) = msg <> ": " <> varname
--showError (BadSpecialForm msg form) = msg <> ": " <> show form
--showError (NotFunction msg func) = msg <> ": " <> show func
--
--showError (NumArgs expected found) = "Expected " <> show expected
--                                   <> " args; found values: " <> unwordsList found
--
--showError (TypeMismatch expected found) = "Invalid type: expected " <> expected
--                                   <> ", found " <> show found
--
--showError (Parser parseErr) = "Parser error at " <> show parseErr
--
----
---- Evaluator
----
--
--eval :: Env -> LispVal -> IOThrowsError LispVal
--eval env val@(String _) = pure val
--eval env val@(Char _) = pure val
--eval env val@(Number _) = pure val
--eval env val@(Bool _) = pure val
--eval env (Atom id) = getVar env id
--eval env (List [Atom "quote", val]) = pure val
--
--eval env (List [Atom "if", prev, conseq, alt]) = do
--    result <- eval env prev
--    case result of
--        Bool False -> eval env alt
--        Bool True  -> eval env conseq
--        _          -> throwError $ TypeMismatch "boolean" result
--
--eval env (List [Atom "cond"]) = throwError ExpectCondClauses
--eval env (List (Atom "cond" : cs)) = evalConds env cs
--eval env (List [Atom "case"]) = throwError ExpectCaseClauses
--
--eval env (List (Atom "case" : key : cs)) = do
--    keyVal <- eval env key
--    evalCaseCases env keyVal cs
--
--eval env (List [Atom "set!", Atom var, form]) =
--    eval env form >>= setVar env var
--
--eval env (List [Atom "define", Atom var, form]) =
--    eval env form >>= defineVar env var
--
--eval env (List (Atom "define" : List (Atom var : params) : body)) =
--    makeNormalFunc env params body >>= defineVar env var
--
--eval env (List (Atom "define" : DottedList (Atom var : params) varargs : body)) =
--    makeVarargs varargs env params body >>= defineVar env var
--
--eval env (List (Atom "lambda" : List params : body)) =
--    makeNormalFunc env params body
--
--eval env (List (Atom "lambda" : DottedList params varargs : body)) =
--    makeVarargs varargs env params body
--
--eval env (List (Atom "lambda" : varargs@(Atom _) : body)) =
--    makeVarargs varargs env [] body
--
--eval env (List [Atom "load", String filename]) =
--    load filename >>= fmap Unsafe.last . mapM (eval env)
--
--eval env (List (function : args)) = do
--    func <- eval env function
--    argVals <- mapM (eval env) args
--    apply func argVals
--
--eval env badForm = throwError $ BadSpecialForm "Unrecognized special form" badForm
--
----
---- Evaluator Helpers
----
--
--evalConds :: Env -> [LispVal] -> IOThrowsError LispVal
--evalConds env [List (Atom "else" : xs)] = evalCondElse env xs
--evalConds _ []                          = throwError ExpectCondClauses
--evalConds env (List clause : cs)        = evalCondClause env clause cs
--evalConds _ badClauses                  = throwError $ TypeMismatch "cond clauses" $ List badClauses
--
--evalCondClause env (test : xs) rest = do
--    result <- eval env test
--    case test of
--         Bool False -> evalConds env rest
--         Bool True  -> trueDo xs
--         _          -> throwError $ TypeMismatch "boolean" result
--  where
--    trueDo [] = pure $ Bool True
--    trueDo xs = evalToLast env xs
--
--evalCondElse :: Env -> [LispVal] -> IOThrowsError LispVal
--evalCondElse _ []   = throwError ExpectCondClauses
--evalCondElse env xs = evalToLast env xs
--
--evalCaseCases :: Env -> LispVal -> [LispVal] -> IOThrowsError LispVal
--evalCaseCases _ _ [] = throwError ExpectCaseClauses
--evalCaseCases env _ [List (Atom "else" : cExprs)] = evalToLast env cExprs
--evalCaseCases env key ((List ((List cKeys) : cExprs)) : cs) = do
--    let result = any (anyOf . (\ x -> eqv [key, x])) cKeys
--    if result
--      then evalCaseCases env key cs
--      else evalToLast env cExprs
--  where
--    anyOf (Right (Bool True)) = True
--    anyOf _                   = False
--evalCaseCases _ _ _ = throwError ExpectCaseClauses
--
--evalToLast :: Env -> [LispVal] -> IOThrowsError LispVal
--evalToLast _ []   = throwError $ NumArgs 1 []
--evalToLast env xs = Unsafe.last <$> mapM (eval env) xs
--
----
---- Primitive functions lookup table
----
--primitives :: [(String, [LispVal] -> ThrowsError LispVal)]
--primitives = [("+", numericBinop (+))
--             ,("-", numericBinop (-))
--             ,("*", numericBinop (*))
--             ,("/", numericBinop div)
--             ,("mod", numericBinop mod)
--             ,("quotient", numericBinop quot)
--             ,("remainder", numericBinop rem)
--             ,("=", numBoolBinop (==))
--             ,("<", numBoolBinop (<))
--             ,(">", numBoolBinop (>))
--             ,("/=", numBoolBinop (/=))
--             ,(">=", numBoolBinop (>=))
--             ,("<=", numBoolBinop (<=))
--             ,("&&", boolBoolBinop (&&))
--             ,("||", boolBoolBinop (||))
--             ,("string=?", strBoolBinop (==))
--             ,("string<?", strBoolBinop (<))
--             ,("string>?", strBoolBinop (>))
--             ,("string<=?", strBoolBinop (<=))
--             ,("string>=?", strBoolBinop (>=))
--             ,("string-ci=?", strBoolBinop (ciHelp (==)))
--             ,("string-ci<?", strBoolBinop (ciHelp (<)))
--             ,("string-ci>?", strBoolBinop (ciHelp (>)))
--             ,("string-ci<=?", strBoolBinop (ciHelp (<=)))
--             ,("string-ci>=?", strBoolBinop (ciHelp (>=)))
--             ,("not", unaryOp not')
--             ,("boolean?", unaryOp boolP)
--             ,("list?", unaryOp listP)
--             ,("symbol?", unaryOp symbolP)
--             ,("char?", unaryOp charP)
--             ,("string?", unaryOp stringP)
--             ,("vector?", unaryOp vectorP)
--             ,("symbol->string", unaryOp symbol2string)
--             ,("string->symbol", unaryOp string2symbol)
--             ,("car", car)
--             ,("cdr", cdr)
--             ,("cons", cons)
--             ,("eqv?", eqv)
--             ,("eq?", eqv)
--             ,("equal?", equal)
--             ,("make-string", makeString)
--             ,("string", createString)
--             ,("string-length", stringLength)
--             ,("string-ref", charAt)
--             ,("substring", substring)
--             ,("string-append", stringAppend)
--             ]
--
----
---- IO Primitives
----
--ioPrimitives :: [(String, [LispVal] -> IOThrowsError LispVal)]
--ioPrimitives = [("apply", applyProc)
--               ,("open-input-file", makePort ReadMode)
--               ,("open-output-file", makePort WriteMode)
--               ,("close-input-port", closePort)
--               ,("close-output-port", closePort)
--               ,("read", readProc)
--               ,("write", writeProc)
--               ,("read-contents", readContents)
--               ,("read-all", readAll)
--               ]
--
----
---- IO Primitive helpers
----
--applyProc :: [LispVal] -> IOThrowsError LispVal
--applyProc [func, List args] = apply func args
--applyProc (func : args)     = apply func args
--
--makePort :: IOMode -> [LispVal] -> IOThrowsError LispVal
--makePort mode [String  filename] = fmap Port $ liftIO $ openFile filename mode
--
--closePort :: [LispVal] -> IOThrowsError LispVal
--closePort [Port port] = liftIO $ hClose port $> Bool True
--closePort _           = pure $ Bool False
--
--readProc :: [LispVal] -> IOThrowsError LispVal
--readProc []          = readProc [Port stdin]
--readProc [Port port] = liftIO (hGetLine port) >>= liftThrows . readExpr
--
--writeProc :: [LispVal] -> IOThrowsError LispVal
--writeProc [obj]            = writeProc [obj, Port stdout]
--writeProc [obj, Port port] = liftIO $ hPrint port obj $> Bool True
--
--readContents :: [LispVal] -> IOThrowsError LispVal
--readContents [String filename] = fmap String $ liftIO $ readFile filename
--
--load :: FilePath -> IOThrowsError [LispVal]
--load filename = liftIO (readFile filename) >>= liftThrows . readExprList
--
--readAll :: [LispVal] -> IOThrowsError LispVal
--readAll [String  filename] = List <$> load filename
--
----
---- Unary primitive defs all have type
---- LispVal -> LispVal
----
--
--not' (Bool x) = (Bool . not) x
--not' _        = Bool False
--
--boolP (Bool _) = Bool True
--boolP _        = Bool False
--
--listP (List _)         = Bool True
--listP (DottedList _ _) = Bool True
--listP _                = Bool False
--
--symbolP (Atom _) = Bool True
--symbolP _        = Bool False
--
--charP (Char _) = Bool True
--charP _        = Bool False
--
--stringP (String _) = Bool True
--stringP _          = Bool False
--
--vectorP (Vector _) = Bool True
--vectorP _          = Bool False
--
--symbol2string (Atom s) = String s
--symbol2string _        = error "Expecting an Atom"
--
--string2symbol (String s) = Atom s
--string2symbol _          = error "Expecting a String"
--
--ciHelp :: (String -> String -> Bool) -> String -> String -> Bool
--ciHelp f a b = f (fmap toLower a) (fmap toLower b)
--
----
---- Other primitives
----
--
--car :: [LispVal] -> ThrowsError LispVal
--car [List (x:xs)]         = pure x
--car [DottedList (x:xs) _] = pure x
--car [badArg]              = throwError $ TypeMismatch "pair" badArg
--car badArgList            = throwError $ NumArgs 1 badArgList
--
--cdr :: [LispVal] -> ThrowsError LispVal
--cdr [List (_:xs)]         = pure $ List xs
--cdr [DottedList [x] _]    = pure x
--cdr [DottedList (_:xs) y] = pure $ DottedList xs y
--cdr [badArg]              = throwError $ TypeMismatch "pair" badArg
--cdr badArgList            = throwError $ NumArgs 1 badArgList
--
--cons :: [LispVal] -> ThrowsError LispVal
--cons [x, List []]            = pure $ List [x]
--cons [x, List xs]            = pure $ List (x:xs)
--cons [x, DottedList xs last] = pure $ DottedList (x:xs) last
--cons [x,y]                   = pure $ DottedList [x] y
--cons badArgList              = throwError $ NumArgs 2 badArgList
--
--eqv :: [LispVal] -> ThrowsError LispVal
--eqv [Bool b1, Bool b2] = (pure . Bool) $ b1 == b2
--eqv [Number n1, Number n2] = (pure . Bool) $ n1 == n2
--eqv [String  s1, String s2] = (pure . Bool) $ s1 == s2
--eqv [Atom a1, Atom a2] = (pure . Bool) $ a1 == a2
--
--eqv [DottedList xs x, DottedList ys y] =
--    eqv [List $ xs <> [x], List $ ys <> [y]]
--
--eqv [List l1, List l2]
--    | length l1 /= length l2 = pure $ Bool False
--    | otherwise = (pure . Bool) $ all byPairs $ zip l1 l2
--  where byPairs (x,y) = case eqv [x,y] of
--                             Left err         -> False
--                             Right (Bool val) -> val
--
--eqv [_, _] = pure $ Bool False
--eqv badArgList = throwError $ NumArgs 2 badArgList
--
--equal :: [LispVal] -> ThrowsError LispVal
--equal [List l1, List l2] = (pure . Bool) $ all byPairs $ zip l1 l2
--  where byPairs (x,y) = case equal [x,y] of
--                             Left _           -> False
--                             Right (Bool val) -> val
--
--equal [DottedList xs x, DottedList ys y] =
--    equal [List $ xs <> [x], List $ ys <> [y]]
--
--equal [arg1, arg2] = do
--    primitiveEquals <- anyM (unpackEquals arg1 arg2) [AnyUnpacker unpackNum, AnyUnpacker unpackStr, AnyUnpacker unpackBool]
--    eqvEquals <- eqv [arg1, arg2]
--    pure $ Bool (primitiveEquals || let (Bool x) = eqvEquals in x)
--
--equal badArgList = throwError $ NumArgs 2 badArgList
--
----
---- String primitives
----
--
--makeString :: [LispVal] -> ThrowsError LispVal
--makeString [Number k, Char c] = pure $ String $ replicate (fromIntegral k)  c
--makeString badArgs            = throwError $ TypeMismatch "int char" $ List badArgs
--
--createString :: [LispVal] -> ThrowsError LispVal
--createString xs
--    | all isChar xs = pure $ String $ foldr f "" xs
--    | otherwise = throwError $ TypeMismatch "list of chars" $ List xs
--  where
--    isChar (Char _) = True
--    isChar _        = False
--    f (Char c) accum = c : accum
--
--stringLength :: [LispVal] -> ThrowsError LispVal
--stringLength [String  s] = (pure . Number . fromIntegral . length) s
--stringLength badArgs     = throwError $ TypeMismatch "string" $ List badArgs
--
--charAt :: [LispVal] -> ThrowsError LispVal
--charAt [String  s, Number n] = (pure . Char) (s !! fromIntegral n)
--charAt badArgs               = throwError $ TypeMismatch "(string number)" $ List badArgs
--
--substring :: [LispVal] -> ThrowsError LispVal
--substring [String  s, Number start, Number end] =
--    let start' = fromIntegral start
--        end' = fromIntegral end
--    in  (pure . String) (drop start' $ take end' s)
--substring badArgs = throwError $ TypeMismatch "(string number number)" $ List badArgs
--
--stringAppend :: [LispVal] -> ThrowsError LispVal
--stringAppend ss
--    | all isString ss = (pure . String) (concatMap (\ (String s) -> s) ss)
--    | otherwise = throwError $ TypeMismatch "list of string" $ List ss
--  where
--    isString (String _) = True
--    isString _          = False
--
----
---- Primitive helpers
----
--
--numericBinop :: (Integer -> Integer -> Integer)
--             -> [LispVal]
--             -> ThrowsError LispVal
--numericBinop _  single@[_] = throwError $ NumArgs 2 single
--numericBinop op params     = mapM unpackNum params <&> (Number . foldl1 op)
--
--numBoolBinop :: (Integer -> Integer -> Bool) -> [LispVal] -> ThrowsError LispVal
--numBoolBinop = boolBinop unpackNum
--
--strBoolBinop :: (String -> String -> Bool) -> [LispVal] -> ThrowsError LispVal
--strBoolBinop = boolBinop unpackStr
--
--boolBoolBinop :: (Bool -> Bool -> Bool) -> [LispVal] -> ThrowsError LispVal
--boolBoolBinop = boolBinop unpackBool
--
--unaryOp :: (LispVal -> LispVal)
--        -> [LispVal]
--        -> ThrowsError LispVal
--unaryOp func [arg] = pure $ func arg
--
--boolBinop :: (LispVal -> ThrowsError a)
--          -> (a -> a -> Bool)
--          -> [LispVal]
--          -> ThrowsError LispVal
--boolBinop unpacker op [x,y] = do
--    left <- unpacker x
--    right <- unpacker y
--    pure $ Bool $ left `op` right
--boolBinop _ _ args = throwError $ NumArgs 2 args
--
--unpackNum :: LispVal -> ThrowsError Integer
--unpackNum (Number n) = pure n
--unpackNum (List [n]) = unpackNum n
--unpackNum notNum     = throwError $ TypeMismatch "number" notNum
--
--unpackStr :: LispVal -> ThrowsError String
--unpackStr (String s) = pure s
--unpackStr (Number s) = pure $ show s
--unpackStr (Bool s)   = pure $ show s
--unpackStr notStr     = throwError $ TypeMismatch "string" notStr
--
--unpackBool :: LispVal -> ThrowsError Bool
--unpackBool (Bool b) = pure b
--unpackBool notBool  = throwError $ TypeMismatch "boolean" notBool
--
--unpackEquals :: LispVal -> LispVal -> Unpacker -> ThrowsError Bool
--unpackEquals arg1 arg2 (AnyUnpacker unpacker) = do
--    unpacked1 <- unpacker arg1
--    unpacked2 <- unpacker arg2
--    pure $ unpacked1 == unpacked2
--  `catchError` const (pure False)
--
----
---- Misc Helpers
----
--
--escapedChars :: Parser Char
--escapedChars = do
--             char '\\'
--             c <- oneOf ['\\','"', 'n', 'r', 't']
--             pure $ case c of
--                    '\\' -> c
--                    '"'  -> c
--                    'n'  -> '\n'
--                    'r'  -> '\r'
--                    't'  -> '\t'
--
--symbol :: Parser Char
--symbol = oneOf "!$%&|*+-/:<=>?@^_~"
--
--spaces :: Parser ()
--spaces = skipMany1 space
--
--bin2int :: String -> Integer
--bin2int s = sum $ zipWith (\ i x -> i * (2 ^ x)) [0 .. ] (fmap p (reverse s)) where
--  p '0' = 0
--  p '1' = 1
--
--readWith :: (t -> [(a, b)]) -> t -> a
--readWith f s = fst $ f s !! 0
--
--unwordsList :: [LispVal] -> String
--unwordsList = toString . unwords . fmap (toText . showVal)
--
--apply :: LispVal -> [LispVal] -> IOThrowsError LispVal
--apply (PrimitiveFunc func) args = liftThrows $ func args
--
--apply (Func params varargs body closure) args =
--    if num params /= num args && isNothing varargs
--       then throwError $ NumArgs (num params) args
--       else liftIO (bindVars closure $ zip params args) >>= bindVarArgs varargs >>= evalBody
--    where remainingArgs = drop (length params) args
--          num = toInteger . length
--          evalBody env = Unsafe.last <$> mapM (eval env) body
--          bindVarArgs arg env = case arg of
--              Just argName -> liftIO $ bindVars env [(argName, List remainingArgs)]
--              Nothing      -> pure env
--
--apply (IOFunc func) args = func args
--
--trapError :: (MonadError a1 m, Show a1, IsString a2) => m a2 -> m a2
--trapError action = catchError action (pure . show)
--
--extractValue :: ThrowsError a -> a
--extractValue (Right val) = val
--
--flushStr :: String -> IO ()
--flushStr s = putStr s *> hFlush stdout
--
--readPrompt :: String -> IO String
--readPrompt prompt = toString <$> (flushStr prompt *> getLine)
--
--evalString :: Env -> String -> IO String
--evalString env expr = runIOThrows $ fmap show $ liftThrows (readExpr expr) >>= eval env
--
--evalAndPrint :: Env -> String -> IO ()
--evalAndPrint env expr = evalString env expr >>= putStrLn
--
--until_ :: Monad m => (a -> Bool) -> m a -> (a -> m ()) -> m ()
--until_ prev prompt action = do
--    result <- prompt
--    if prev result
--       then pass
--       else action result *> until_ prev prompt action
--
--nullEnv :: IO Env
--nullEnv = newIORef []
--
--liftThrows :: ThrowsError a -> IOThrowsError a
--liftThrows (Left err)  = throwError err
--liftThrows (Right val) = pure val
--
--runIOThrows :: IOThrowsError String -> IO String
--runIOThrows action = runErrorT (trapError action) <&> extractValue
--
--isBound :: Env -> String -> IO Bool
--isBound envRef var = readIORef envRef <&> (isJust . lookup var)
--
--getVar :: Env -> String -> IOThrowsError LispVal
--getVar envRef var = do
--    env <- liftIO $ readIORef envRef
--    maybe (throwError $ UnboundVar "Getting an unbound variable" var)
--          (liftIO . readIORef)
--          (lookup var env)
--
--setVar :: Env -> String -> LispVal -> IOThrowsError LispVal
--setVar envRef var value = do
--    env <- liftIO $ readIORef envRef
--    maybe (throwError $ UnboundVar "Setting an unbound variable" var)
--          (liftIO .  (`writeIORef` value))
--          (lookup var env)
--    pure value
--
--defineVar :: Env -> String -> LispVal -> IOThrowsError LispVal
--defineVar envRef var value = do
--    alreadyDefined <- liftIO $ isBound envRef var
--    if alreadyDefined
--       then setVar envRef var value $> value
--       else liftIO $ do
--           valueRef <- newIORef value
--           env <- readIORef envRef
--           writeIORef envRef ((var, valueRef) : env)
--           pure value
--
--bindVars :: Env -> [(String, LispVal)] -> IO Env
--bindVars envRef bindings = readIORef envRef >>= extendEnv bindings >>= newIORef
--  where extendEnv bindings env = fmap (<> env) (mapM addBinding bindings)
--        addBinding (var, value) = do
--            ref <- newIORef value
--            pure (var, ref)
--
--primitiveBindings :: IO Env
--primitiveBindings = nullEnv >>= flip bindVars (fmap (makeFunc' IOFunc) ioPrimitives <> fmap (makeFunc' PrimitiveFunc) primitives)
--  where makeFunc' constructor (var, func) = (var, constructor func)
--
--makeFunc :: Applicative f => Maybe String -> Env -> [LispVal] -> [LispVal] -> f LispVal
--makeFunc varargs env params body = pure $ Func (fmap showVal params) varargs body env
--
--makeNormalFunc :: Env -> [LispVal] -> [LispVal] -> ErrorT LispError IO LispVal
--
--makeNormalFunc = makeFunc Nothing
--
--makeVarargs :: LispVal -> Env -> [LispVal] -> [LispVal] -> ErrorT LispError IO LispVal
--makeVarargs = makeFunc . Just . showVal
