module Test.Main (main) where

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (logShow)
import Data.Enum (toEnum)
import Data.Maybe (Maybe)
import Test.QuickCheck (class Arbitrary, (===))
import Test.QuickCheck.Gen (choose)
import Test.Spec (describe, it)
import Test.Spec.QuickCheck (QCRunnerEffects, quickCheck)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (run)
import Prelude

import Pitch (Pitch(..), Note, pitchToNote, notePitches, pitchNotes)

main :: Eff (QCRunnerEffects ()) Unit
main = do
  logShow notePitches
  logShow pitchNotes
  run [consoleReporter] do
    describe "pitchToNote algorithm" do
      it "works for pitches below 27.5 Hz" $
        quickCheck \(LowPitch p) -> pitchToNote p === bottom

newtype LowPitch = LowPitch Pitch
instance arbitraryLowPitch :: Arbitrary LowPitch
  where arbitrary = LowPitch <<< Pitch <$> choose 0.0 27.5
