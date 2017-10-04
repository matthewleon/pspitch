module Test.Main (main) where

import Control.Monad.Eff (Eff)
import Test.Float32Array (testFloat32Array)
import Test.Pitch (testPitch)
import Test.Waveform (testWaveform)
import Test.Spec.QuickCheck (QCRunnerEffects)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (run)
import Prelude

main :: Eff (QCRunnerEffects ()) Unit
main = testWaveform
{-
main = run [consoleReporter] do
  testWaveform
  testFloat32Array
  testPitch
-}
