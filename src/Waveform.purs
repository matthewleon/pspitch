module Waveform where

import Float32Array (Float32Array)
import Float32Array as F32A
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Int (toNumber, ceil, floor)
import Prelude

data Waveform = Waveform (Array Int) Int Int
derive instance genericWaveform :: Generic Waveform _
derive instance eqWaveform :: Eq Waveform
instance showWaveform :: Show Waveform
  where show = genericShow

{-
buckets :: Int -> Int -> Array (Tuple Int Int)
buckets numberOfSamples numberOfBuckets =
  where
  samplesPerBucket = toNumber numberOfSamples / toNumber samplesPerBucket
-}

{-
renderToWaveform :: Int -> Int -> Float32Array -> Waveform
renderToWaveform width height pcmData = range 0 (width - 1) <#> \binIndex ->
  F32A.mean $
    subarray pcmData (binOffset * binIndex) (binOffset * binIndex + samplesPerBin)
    <#> flip F32A.map abs
  where
    samplesPerBinFloat = toNumber (F32A.length pcmData) / toNumber width
    samplesPerBin      = ceil  samplesPerBinFloat
    binOffset          = floor samplesPerBinFloat
-}
