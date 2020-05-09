module HelVM.HelMS.Calculus.Reducers.SkiReducer (
  reduceSki,
) where

import           HelVM.HelPA.Assemblers.Calculus.Instruction

reduceSki :: Instruction -> Instruction
reduceSki = fst . flip reduceSkiWithIndex 0

reduceSkiWithIndex :: Instruction -> Int -> (Instruction , Int)
reduceSkiWithIndex (App f a) n = reduceApp f a n
reduceSkiWithIndex S         n = (reduceS n       , n + 1)
reduceSkiWithIndex K         n = (reduceK n       , n + 1)
reduceSkiWithIndex I         n = (reduceI n       , n + 1)
reduceSkiWithIndex _         _ = error "reduceSkiWithIndex"

reduceApp :: Instruction -> Instruction -> Int -> (Instruction , Int)
reduceApp f a n = (App f' a' , n'') where
  (a', n'') = reduceSkiWithIndex a n'
  (f', n')  = reduceSkiWithIndex f n

reduceS :: Int -> Instruction
reduceS n = fx $ fy $ fz $ x `App` z `App` App y z where
  (fx, x) = makeFunWithVarX n
  (fy, y) = makeFunWithVarY n
  (fz, z) = makeFunWithVarZ n

reduceK :: Int -> Instruction
reduceK n = fx $ fy x where
  (fx, x) = makeFunWithVarX n
  (fy, _) = makeFunWithVarY n

reduceI :: Int -> Instruction
reduceI n = fx x where
  (fx , x) = makeFunWithVarX n

makeFunWithVarX :: Int -> (Instruction -> Instruction , Instruction)
makeFunWithVarX = makeFunWithVar "x"

makeFunWithVarY :: Int -> (Instruction -> Instruction , Instruction)
makeFunWithVarY = makeFunWithVar "y"

makeFunWithVarZ :: Int -> (Instruction -> Instruction , Instruction)
makeFunWithVarZ = makeFunWithVar "z"

makeFunWithVar :: Text -> Int -> (Instruction -> Instruction , Instruction)
makeFunWithVar t a = (Abs &&& Var) (t <> show a)
