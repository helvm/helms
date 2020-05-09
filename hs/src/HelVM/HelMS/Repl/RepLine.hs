module HelVM.HelMS.Repl.RepLine (repl) where

import qualified HelVM.HelMS.Repl.Option as Option
import           HelVM.HelMS.Repl.Types

import           Data.Function.Tools

import qualified Data.Set                as Set
import qualified Data.Text               as Text

import           System.Console.Repline

repl :: IO ()
repl = flip evalStateT Set.empty $ evalReplOpts $ ReplOpts
  { banner           = helBanner
  , command          = helCommand
  , options          = Option.coreOptions
  , prefix           = Just Option.prefix
  , multilineCommand = Just $ toString Option.pasteActionName
  , tabComplete      = Prefix wordCompletionFunc matcher
  , initialiser      = initializer
  , finaliser        = finalizer
  }

helBanner :: MultiLine -> Repl String
helBanner SingleLine = pure "& "
helBanner MultiLine  = pure ""

initializer :: Repl ()
initializer = putTextLn "Welcome to HELMS"

finalizer :: Repl ExitDecision
finalizer = pure Exit

helCommand :: Action
helCommand = apply2way (*>) (modify . Set.insert) putTextLn . toText

-- | Matcher
matcher :: MonadRepl m => [(String, CompletionFunc m)]
matcher =
  [ (":help"    , wordCompletionFunc)
  , (":holiday" , listCompleter ["christmas", "thanksgiving", "festivus"])
  , (":load"    , fileCompleter)
  ]

wordCompletionFunc :: MonadRepl m => CompletionFunc m
wordCompletionFunc = wordCompleter completer

-- | Completer
completer :: MonadRepl m => WordCompleter m
completer prefix = completerFilter prefix <$> get

completerFilter :: String -> ReplState -> [String]
completerFilter prefix replState = toString <$> filter (Text.isPrefixOf $ toText prefix) (Option.names <> Set.toList replState)
