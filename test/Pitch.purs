module Test.Pitch (testPitch) where

import Data.Enum (pred, succ)
import Data.Maybe (fromJust)
import Test.QuickCheck (class Arbitrary, (===))
import Test.QuickCheck.Gen (choose)
import Test.Spec.QuickCheck (QCRunnerEffects, quickCheck)
import Test.Spec (Spec, describe, it)
import Partial.Unsafe (unsafePartial)
import Prelude

import Pitch (Pitch(..), pitchToNote, noteToPitch)

testPitch :: Spec (QCRunnerEffects ()) Unit
testPitch = describe "pitchToNote algorithm" do
  it "works for pitches below 27.5 Hz" $
    quickCheck \(LowPitch p) -> pitchToNote p === bottom
  it "works for pitches above 4186.01 Hz" $
    quickCheck \(HighPitch p) -> pitchToNote p === top
  it "works for pitches between 27.5 Hz and 4186.01 Hz" $
    quickCheck \(MidPitch p) ->
      let note = pitchToNote p
      in  case compare p $ noteToPitch note of
          GT -> p < (noteToPitch <<< unsafePartial $ fromJust $ succ note)
          LT -> p > (noteToPitch <<< unsafePartial $ fromJust $ pred note)
          EQ -> true

newtype LowPitch = LowPitch Pitch
instance arbitraryLowPitch :: Arbitrary LowPitch
  where arbitrary = LowPitch <<< Pitch <$> choose 0.0 27.5

newtype HighPitch = HighPitch Pitch
instance arbitraryHighPitch :: Arbitrary HighPitch
  where arbitrary = HighPitch <<< Pitch <$> choose 4186.01 9007199254740991.0

newtype MidPitch = MidPitch Pitch
instance arbitraryMidPitch :: Arbitrary MidPitch
  where arbitrary = MidPitch <<< Pitch <$> choose 27.5 4186.01
