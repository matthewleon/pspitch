module Test.Waveform (testWaveform) where

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, logShow)
import Data.Array (replicate)
import Test.QuickCheck (class Arbitrary, (===))
import Test.QuickCheck.Gen (choose)
import Test.Spec.QuickCheck (QCRunnerEffects, quickCheck)
import Test.Spec (Spec, describe, it)
import Prelude

import Float32Array as F32A
import Waveform as W

testWaveform :: forall eff. Eff (console :: CONSOLE | eff) Unit
testWaveform = logShow <<< W.toWaveform 80 20 <<< F32A.fromArray $ replicate 1000 1.0
{-
testWaveform :: Spec (QCRunnerEffects ()) Unit
testWaveform = describe "Waveform" do
  it "converts arrays correctly" do
    logShow <<< W.toWaveform 80 20 <<< F32A.fromArray $ replicate 1000 1.0
-}
  {-
    let pcmData  =
        waveform = toWaveform 100 10 pcmData
    in --complete me
  -}
