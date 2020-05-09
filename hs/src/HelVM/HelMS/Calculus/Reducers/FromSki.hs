module HelVM.HelMS.Calculus.Reducers.FromSki (
  skiToLambda,
  buildSki,
) where

import           HelVM.HelMS.Calculus.Lambda

import           Data.List                   (minimumBy)

skiToLambda :: Lambda -> Lambda
skiToLambda = betaSki . minimumBy (comparing size) . take 15 . iterate betaReduction

buildSki :: Lambda -> Lambda
buildSki (Abs p1 (Abs p2 (Var v)))
  | p1 == v = K
  | p2 == v = App K I
buildSki (Abs p (Var v))
  | p  == v = I
buildSki (Abs p e) = Abs p (buildSki e)
buildSki (App f a) = App (buildSki f) (buildSki a)
buildSki l         = l

betaSki :: Lambda -> Lambda
betaSki ((p `Abs` v@(Var x)) `App` ar)
  | p == x    = ar
  | otherwise = v
betaSki ((p `Abs` f@(q `Abs` Var x)) `App` a)
  | q == x    = f
  | p == x    = Abs "_" a
betaSki (App f a)  = betaSki f `App` betaSki a
betaSki (Abs p e)  = Abs p $ betaSki e
betaSki l     = l

betaReduction :: Lambda -> Lambda
betaReduction (Abs p    e)  = Abs p (betaReduction e)
betaReduction (App fun arg) = app (betaReduction fun) (betaReduction arg)
betaReduction kiv           = kiv

app :: Lambda -> Lambda -> Lambda
app (Abs p e) arg = para p arg e
app  ex       arg = App ex arg

para :: Text -> Lambda -> Lambda -> Lambda
para p a v@(Var x)
  | p == x     = a
  | otherwise  = v
para p a (App f b) = para p a f `App` para p a b
para p a f@(Abs q e)
  | p == q     = f
  | otherwise  = q `Abs` para p a e
para _ _ l     = l

size :: Lambda -> Int
size (App f a) = size f + size a
size (Abs _ e) = 1 + size e
size _         = 1
