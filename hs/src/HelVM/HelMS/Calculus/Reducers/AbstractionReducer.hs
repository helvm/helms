module HelVM.HelMS.Calculus.Reducers.AbstractionReducer (
  reduceAbstractions,
  reduceCombinatorInLambda,
) where

import           HelVM.HelMS.Calculus.Lambda

reduceAbstractions :: LambdaList -> LambdaList
reduceAbstractions = fmap reduceCombinatorInLambda

reduceCombinatorInLambda :: Lambda -> Lambda
reduceCombinatorInLambda (App f g) = App (reduceCombinatorInLambda f) (reduceCombinatorInLambda g)
reduceCombinatorInLambda (Abs n f) = reduceToSki n f
reduceCombinatorInLambda (Com n f) = Com n (reduceCombinatorInLambda f)
reduceCombinatorInLambda  l        = l

--

onlySKI :: Lambda -> Bool
onlySKI S         = True
onlySKI K         = True
onlySKI I         = True
onlySKI (App f a) = onlySKI f && onlySKI a
onlySKI _         = False

reduceToSki :: Text -> Lambda -> Lambda
reduceToSki _ e
  | onlySKI e             = App K e
reduceToSki x0 (App f a)  = App (App S $ reduceToSki x0 f) $ reduceToSki x0 a
reduceToSki x0 (Abs x1 e) = reduceFun x0 x1 e
reduceToSki x0 (Var x1)   = reduceVar x0 x1
reduceToSki _ _      = error "never occur"

reduceFun :: Text -> Text -> Lambda -> Lambda
reduceFun x0 x1 e
  | x0 == x1  = App K $ reduceToSki x0 e
  | otherwise = reduceToSki x0 $ reduceToSki x1 e

reduceVar :: Text -> Text -> Lambda
reduceVar x0 x1
  | x1 == x0  = I
  | otherwise = App K (Var x1)
