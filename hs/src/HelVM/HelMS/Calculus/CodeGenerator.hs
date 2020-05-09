module HelVM.HelMS.Calculus.CodeGenerator (
  generateCode,
  generateZot,
  generateUnLambda,
  generateCalculus,
) where

import           HelVM.HelMS.Calculus.Lambda

import           HelVM.HelMS.Calculus.API.CalculusType

generateCode :: CalculusType -> Lambda -> Text
generateCode Zot        = generateZot
generateCode UnLambda   = generateUnLambda
generateCode Combinator = generateCalculus
generateCode Lambda     = generateCalculus

----

generateZot :: Lambda -> Text
generateZot S         = "101010100"
generateZot K         = "1010100"
generateZot I         = "100"
generateZot (App f a) = "1" <> generateZot f <> generateZot a
generateZot (Abs _ _) = error "fun"
generateZot (Var _)   = error "var"
generateZot (Com _ _) = error "com"
generateZot (Nat _  ) = error "nat"
generateZot Nop       = error "nop"

generateUnLambda :: Lambda -> Text
generateUnLambda S         = "s"
generateUnLambda K         = "k"
generateUnLambda I         = "i"
generateUnLambda (App f a) = "`" <> generateUnLambda f <> generateUnLambda a
generateUnLambda (Abs p e) = "(fun " <> p <> " " <> generateUnLambda e <> ")"
generateUnLambda (Var v  ) = "(var " <> v <> ")"
generateUnLambda (Com _ _) = error "com"
generateUnLambda (Nat _  ) = error "nat"
generateUnLambda Nop       = error "nop"

generateCalculus :: Lambda -> Text
generateCalculus S           = "S"
generateCalculus K           = "K"
generateCalculus I           = "I"
generateCalculus a@(App _ _) = showAp a
generateCalculus f@(Abs _ _) = "\\" <> showFun f
generateCalculus (Var v)     = v
generateCalculus (Com _ _)   = error "com"
generateCalculus (Nat _  )   = error "nat"
generateCalculus Nop         = error "nop"

showFun :: Lambda -> Text
showFun (Abs p e) = p <> " " <> showFun e
showFun e         = "-> " <> generateCalculus e

showAp :: Lambda -> Text
showAp (App f a) = showAp f <> " " <> par generateCalculus a
showAp e         = par generateCalculus e

par :: (Lambda -> Text) -> Lambda -> Text
par sh a@(App _ _) = "(" <> sh a <> ")"
par sh f@(Abs _ _) = "(" <> sh f <> ")"
par sh e           = sh e
