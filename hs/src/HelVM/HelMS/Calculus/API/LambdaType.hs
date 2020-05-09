module HelVM.HelMS.Calculus.API.LambdaType where

import           HelVM.HelMS.Calculus.API.SwitchEnum

parseLambdaType :: String -> LambdaType
parseLambdaType raw = valid $ readMaybe raw where
  valid (Just value) = value
  valid Nothing      = error $ "'" <> toText raw <> "' is not valid LambdaType. Valid LambdaType are : " <> show lambdaTypes

defaultLambdaType :: LambdaType
defaultLambdaType = defaultEnum

lambdaTypes :: [LambdaType]
lambdaTypes = [NamedLambda , IndexedLambda , SkiCombinator]

data LambdaType = NamedLambda | IndexedLambda | SkiCombinator
  deriving stock (Bounded , Enum , Eq , Read , Show)
