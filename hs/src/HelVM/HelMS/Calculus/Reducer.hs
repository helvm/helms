module HelVM.HelMS.Calculus.Reducer (
  reduceSafe,
) where

import           HelVM.HelMS.Calculus.Reducers.AbstractionReducer
import           HelVM.HelMS.Calculus.Reducers.DefinedCombinatorReducer
import           HelVM.HelMS.Calculus.Reducers.DefinedCombinatorRemover

import           HelVM.HelMS.Calculus.Lambda

import           HelVM.Common.Control.Safe


reduceSafe :: LambdaList -> Safe Lambda
reduceSafe = check . reduce where
  check :: LambdaList -> Safe Lambda
  check [l] = pure l
  check  ll = liftErrorWithPrefix "code" $ show ll

reduce :: LambdaList -> LambdaList
reduce = removeDefinedCombinators . reduceDefinedCombinators . reduceAbstractions
