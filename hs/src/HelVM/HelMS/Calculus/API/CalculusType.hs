module HelVM.HelMS.Calculus.API.CalculusType where

isLambda :: CalculusType -> Bool
isLambda Lambda = True
isLambda _      = False

parseCalculusType :: String -> CalculusType
parseCalculusType raw = valid $ readMaybe raw where
  valid (Just value) = value
  valid Nothing      = error $ "'" <> toText raw <> "' is not valid CalculusType. Valid calculusTypes are : " <> show calculusTypes

inputCalculusType :: CalculusType
inputCalculusType = Zot

outputCalculusType :: CalculusType
outputCalculusType = Lambda

inputCalculusTypes :: [CalculusType]
--inputCalculusTypes = [Zot , UnLambda , Lambda]
inputCalculusTypes = [Zot]

calculusTypes :: [CalculusType]
calculusTypes = [Zot , UnLambda , Combinator , Lambda]

data CalculusType = Zot | UnLambda | Combinator | Lambda
  deriving stock (Bounded , Enum , Eq , Read , Show)
