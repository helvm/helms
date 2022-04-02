module HelVM.HelMS.Calculus.Parsers.FileUtil (
  readLangFile,
  readSourceFile,
  buildAbsoluteSkiFileName,
  buildAbsoluteCombinatorFileName,
  buildAbsoluteAbstractionFileName,
  buildAbsoluteIlFileName,
  buildAbsoluteLangFileName,
  buildAbsoluteModeFileName,
  buildAbsoluteExtFileName,
  buildAbsoluteOutFileName,
  buildAbsoluteLogFileName,
  buildAbsoluteEvalFileName,
  showAscii,
  options,
) where

import           System.FilePath.Posix

readLangFile :: MonadIO m => FilePath -> FilePath -> m Text
readLangFile lang fileName = readSourceFile $ lang  </> fileName <.> lang

readSourceFile :: MonadIO m => FilePath -> m Text
readSourceFile filePath = readFileText $ "examples" </> filePath

buildAbsoluteSkiFileName :: FilePath -> FilePath -> FilePath
buildAbsoluteSkiFileName = buildAbsoluteExtFileName "ski"

buildAbsoluteCombinatorFileName :: FilePath -> FilePath -> FilePath
buildAbsoluteCombinatorFileName = buildAbsoluteExtFileName "combinator"

buildAbsoluteAbstractionFileName :: FilePath -> FilePath -> FilePath
buildAbsoluteAbstractionFileName = buildAbsoluteExtFileName "abstraction"

buildAbsoluteIlFileName :: FilePath -> FilePath -> FilePath
buildAbsoluteIlFileName = buildAbsoluteExtFileName "il"

buildAbsoluteLangFileName :: FilePath -> FilePath -> FilePath
buildAbsoluteLangFileName lang fileName = lang </> fileName <.> lang

buildAbsoluteModeFileName :: FilePath -> FilePath -> FilePath -> FilePath
buildAbsoluteModeFileName mode lang fileName = lang </> mode </> fileName <.> lang

buildAbsoluteExtFileName :: FilePath -> FilePath -> FilePath -> FilePath
buildAbsoluteExtFileName ext lang fileName = lang </> ext </> fileName <.> ext

buildAbsoluteOutFileName :: FilePath -> FilePath -> FilePath
buildAbsoluteOutFileName = buildAbsoluteEvalFileName "output"

buildAbsoluteLogFileName :: FilePath -> FilePath -> FilePath
buildAbsoluteLogFileName = buildAbsoluteEvalFileName "logged"

buildAbsoluteEvalFileName :: FilePath -> FilePath -> FilePath -> FilePath
buildAbsoluteEvalFileName mode lang fileName = lang </> "eval" </> mode </> fileName <.> mode

showAscii:: Bool -> FilePath
showAscii False = "asciiOff"
showAscii True  = "asciiOn"

options :: [Bool]
options = [True , False]
