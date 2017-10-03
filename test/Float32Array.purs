module Test.Float32Array (testFloat32Array) where

import Data.Foldable (sum)
import Data.Int (toNumber)
import Test.QuickCheck ((===))
import Test.Spec.QuickCheck (QCRunnerEffects, quickCheck)
import Test.Spec (Spec, describe, it)
import Prelude

import Float32Array as F32A

testFloat32Array :: Spec (QCRunnerEffects ()) Unit
testFloat32Array = describe "Float32Array" do
  describe "array conversion for integral values" $
    it "works" $ quickCheck \arr ->
      (toNumber <$> arr) === F32A.toArray (F32A.fromArray $ toNumber <$> arr)
  describe "sum" $
    it "correctly sums entries" $ quickCheck \arr ->
      toNumber (sum arr) === F32A.sum (F32A.fromArray $ toNumber <$> arr)
  -- TODO: truncation of Numbers to 32 bits makes other tests tricky
