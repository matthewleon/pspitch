module Test.Main (main) where

import Control.Monad.Eff (Eff)
import Test.Pitch (testPitch)
import Test.Spec.QuickCheck (QCRunnerEffects)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (run)
import Prelude

main :: Eff (QCRunnerEffects ()) Unit
main = run [consoleReporter] do
  testPitch
