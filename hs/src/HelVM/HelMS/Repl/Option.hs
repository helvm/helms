module HelVM.HelMS.Repl.Option where

import           HelVM.HelMS.Repl.Types

import           HelVM.Common.Util

import qualified Data.Text              as Text

import           UnliftIO.Process

holidaysAction :: Action
holidaysAction "" = putStrLn "Enter a holiday."
holidaysAction xs = putStrLn $ "Happy " <> xs <> "!"

loadAction :: Action
loadAction filePath = putStrLn =<< readFile filePath

sayAction :: Action
sayAction args = callCommand $ "cowsay" <> " " <> args

helpAction :: Action
helpAction = putTextLn . descriptionForName . fromMaybe "" . headMaybe . words . toText

descriptionForName :: Text -> Text
descriptionForName = tee descriptionForNameDef descriptionForNameMaybe

descriptionForNameMaybe :: Text -> Maybe Text
descriptionForNameMaybe optionName = snd <$> find (foundPrefixedNameWithDescription optionName) prefixedNamesWithDescriptions

descriptionForNameDef :: Text -> Maybe Text -> Text
descriptionForNameDef optionName = fromMaybe ("Unknown option: " <> optionName)

coreOptions :: [NamedAction]
coreOptions = namedAction <$> coreDescribedOptions

prefixedNamesWithDescriptions :: [PrefixedNameWithDescription]
prefixedNamesWithDescriptions = [(":paste" , "MultiLine mode") , ("",  "Help for: " <> unwords names)] <> fmap prefixedNameWithDescription coreDescribedOptions

foundPrefixedNameWithDescription :: Text -> PrefixedNameWithDescription -> Bool
foundPrefixedNameWithDescription key (pn , _) = key == pn

names :: [Text]
names = withPrefix pasteActionName : fmap prefixedName coreDescribedOptions

-- | Options
pasteActionName :: Text
pasteActionName = "paste"

coreDescribedOptions :: [DescribedOption]
coreDescribedOptions =
  [ DescribedOption "help"    helpAction     "This help"
  , DescribedOption "load"    loadAction     "Load file"
  , DescribedOption "holiday" holidaysAction "Choose holideys"
  , DescribedOption "say"     sayAction      "Say something"
  ]

-- | Accessors
namedAction :: DescribedOption -> NamedAction
namedAction otp = (toString $ name otp , action otp)

prefixedNameWithDescription :: DescribedOption -> PrefixedNameWithDescription
prefixedNameWithDescription opt = (prefixedName opt , description opt)

prefixedName :: DescribedOption -> Text
prefixedName = withPrefix . name

withPrefix :: Text -> Text
withPrefix = Text.cons prefix

prefix :: Char
prefix = ':'

-- | Types
type PrefixedNameWithDescription = (Text, Text)

data DescribedOption = DescribedOption
  { name        :: Text
  , action      :: Action
  , description :: Text
  }
