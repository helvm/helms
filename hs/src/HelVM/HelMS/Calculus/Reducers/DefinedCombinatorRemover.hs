module HelVM.HelMS.Calculus.Reducers.DefinedCombinatorRemover where

import           HelVM.HelMS.Calculus.Lambda

removeDefinedCombinators :: LambdaList -> LambdaList
removeDefinedCombinators = filter isCombinator
