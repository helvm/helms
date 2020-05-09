module Main (main) where

import           AppOptions

import           HelVM.HelMS.Repl.RepLine

import           Options.Applicative

main :: IO ()
main = runApp =<< execParser opts where
  opts = info (optionParser <**> helper)
     (  fullDesc
     <> header "HelMA: The Interpreter of BrainFuck , ETA , SubLeq and WhiteSpace"
     <> progDesc "Runs esoteric programs - complete with pretty bad error messages"
     )

runApp:: AppOptions -> IO ()
runApp _ = repl
