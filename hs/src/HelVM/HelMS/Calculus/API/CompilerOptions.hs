module HelVM.HelMS.Calculus.API.CompilerOptions where

import           HelVM.HelMS.Calculus.API.Separator

import           HelVM.HelMS.Calculus.API.CalculusType

data CompilerOptions = CompilerOptions
  { separator  :: Maybe Separator
  , outputType :: CalculusType
  }
