module HelVM.HelMS.Calculus.Parsers.FileUtil (
  readHlcFile,
  readSourceFile,
  buildAbsoluteHlcFileName,
  buildAbsoluteHlcSkiFileName,
  buildAbsoluteHlcCombinatorFileName,
  buildAbsoluteHlcAbstractionFileName,
  buildAbsoluteHlcIlFileName,
  buildAbsoluteLangFileName,
  buildAbsoluteModeFileName,
  buildAbsoluteIlFileName,
  buildAbsoluteExtFileName,
  buildAbsoluteOutFileName,
  buildAbsoluteLogFileName,
  buildAbsoluteEvalFileName,
  showAscii,
  options,
) where

import           System.FilePath.Posix

readHlcFile :: MonadIO m => FilePath -> m Text
readHlcFile = readLangFile "hlc"

readLangFile :: MonadIO m => FilePath -> FilePath -> m Text
readLangFile lang fileName = readSourceFile $ lang  </> fileName <.> lang

readSourceFile :: MonadIO m => FilePath -> m Text
readSourceFile filePath = readFileText $ "examples" </> filePath

buildAbsoluteHlcFileName :: FilePath -> FilePath
buildAbsoluteHlcFileName = buildAbsoluteLangFileName "hlc"

buildAbsoluteHlcSkiFileName :: FilePath -> FilePath
buildAbsoluteHlcSkiFileName = buildAbsoluteExtFileName "ski" "hlc"

buildAbsoluteHlcCombinatorFileName :: FilePath -> FilePath
buildAbsoluteHlcCombinatorFileName = buildAbsoluteExtFileName "combinator" "hlc"

buildAbsoluteHlcAbstractionFileName :: FilePath -> FilePath
buildAbsoluteHlcAbstractionFileName = buildAbsoluteExtFileName "abstraction" "hlc"

buildAbsoluteHlcIlFileName :: FilePath -> FilePath
buildAbsoluteHlcIlFileName = buildAbsoluteExtFileName "il" "hlc"

buildAbsoluteLangFileName :: FilePath -> FilePath -> FilePath
buildAbsoluteLangFileName lang fileName = lang </> fileName <.> lang

buildAbsoluteModeFileName :: FilePath -> FilePath -> FilePath -> FilePath
buildAbsoluteModeFileName mode lang fileName = lang </> mode </> fileName <.> lang

buildAbsoluteIlFileName :: FilePath -> FilePath -> FilePath
buildAbsoluteIlFileName = buildAbsoluteExtFileName "il"

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
