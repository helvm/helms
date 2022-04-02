module HelVM.HelMS.Calculus.Lambda where

import           HelVM.HelMS.Calculus.Value

import           Text.Megaparsec            hiding (many)

isCombinator :: Lambda -> Bool
isCombinator (Com _ _) = True
isCombinator  _        = False

-- | Types
type LambdaList = [Lambda]

data Lambda =
    Nop
  | S
  | K
  | I
  | App Lambda Lambda
  | Abs Identifier Lambda
  | Var Identifier
  | Nat Natural
  | Com Identifier Lambda
  deriving stock (Eq , Ord , Read , Show)

instance ShowErrorComponent Lambda where
  showErrorComponent = show
