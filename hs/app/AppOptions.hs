module AppOptions where

import           Options.Applicative

optionParser :: Parser AppOptions
optionParser = AppOptions
  <$> strOption    (  long    "repLineType"
                   <> short   'r'
                   <> metavar "[repLineType]"
                   <> help    "RepLineType to choose: "
                   <> value    "defaultRepLineType"
                   <> showDefault
                   )

newtype AppOptions = AppOptions
  { repLineType :: String -- | RepLineType
  }
