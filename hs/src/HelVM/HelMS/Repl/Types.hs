module HelVM.HelMS.Repl.Types where

import           System.Console.Repline

import qualified Data.Set               as Set

type NamedAction = (String , Action)

type Action = String -> Repl ()

type Repl a = HaskelineT (StateT ReplState IO) a

type MonadRepl m = (Monad m, MonadIO m, MonadState ReplState m)

type ReplState = Set.Set Text
