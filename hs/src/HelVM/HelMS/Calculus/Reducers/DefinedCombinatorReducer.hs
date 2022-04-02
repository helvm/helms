module HelVM.HelMS.Calculus.Reducers.DefinedCombinatorReducer (
  reduceDefinedCombinators,
) where

import           HelVM.HelMS.Calculus.Lambda

import           Data.Map                    as Map

reduceDefinedCombinators :: LambdaList -> LambdaList
reduceDefinedCombinators l = reduceCombinatorByMap (buildCombinatorMap l) <$> l

buildCombinatorMap :: LambdaList -> Map Text Lambda
buildCombinatorMap = flip nextCombinatorMap Map.empty

nextCombinatorMap :: LambdaList -> Map Text Lambda -> Map Text Lambda
nextCombinatorMap            [] m = m
nextCombinatorMap (Com n f : l) m = nextCombinatorMap l $ insert n (reduceCombinatorByMap m f) m
nextCombinatorMap (_       : l) m = nextCombinatorMap l m

reduceCombinatorByMap :: Map Text Lambda -> Lambda -> Lambda
reduceCombinatorByMap m (App f g) = App (reduceCombinatorByMap m f) (reduceCombinatorByMap m g)
reduceCombinatorByMap m (Abs n f) = Abs n $ reduceCombinatorByMap m f
reduceCombinatorByMap m (Com n f) = Com n $ reduceCombinatorByMap m f
reduceCombinatorByMap m v@(Var n) = fromMaybe v $ lookup n m
reduceCombinatorByMap _         l = l

--isNatural :: Text -> Bool
--isNatural n =

--var m n = lookup n m

