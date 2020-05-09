module HelVM.HelMS.Calculus.Reducers.NaturalReducer where

import           HelVM.Common.ReadText

import           HelVM.HelMS.Calculus.Lambda

reduceNaturals :: LambdaList -> LambdaList
reduceNaturals = map reduceNatural

reduceNatural :: Lambda -> Lambda
reduceNatural (App f g) = App (reduceNatural f) (reduceNatural g)
reduceNatural (Abs n f) = Abs n $ reduceNatural f
reduceNatural (Com n f) = Com n $ reduceNatural f
reduceNatural (Var n)   = var n
reduceNatural  l        = l

var :: Text -> Lambda
var name = check (readTextMaybe name :: Maybe Natural) where
  check (Just a) = convertNatural a
  check Nothing  = Var name

convertNatural :: Natural -> Lambda
convertNatural = Abs "f" . Abs "x" . convertNaturalRec

convertNaturalRec :: Natural -> Lambda
convertNaturalRec 0 = zero
convertNaturalRec n = successor $ convertNaturalRec (n-1)

zero :: Lambda
zero = Var "x"

successor :: Lambda -> Lambda
successor = App varF

varF :: Lambda
varF = Var "f"
