module Waveform (
  Waveform
, toWaveform
, toString
) where

import Float32Array (Float32Array)
import Float32Array as F32A
import Data.Array as Array
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Int (round, toNumber, ceil, floor)
import Data.String (joinWith, fromCharArray)
import Math (abs)
import Prelude

data Waveform = Waveform (Array Int) Int
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

toWaveform :: Int -> Int -> Float32Array -> Waveform
toWaveform width height pcmData = Waveform histogram height
  where
  histogram = Array.range 0 (width - 1) <#> \binIndex ->
    round <<< (_ * toNumber height) <<< F32A.mean <<< flip F32A.map abs $
      F32A.subarray
        pcmData (binOffset * binIndex) (binOffset * binIndex + samplesPerBin)
    where
    samplesPerBinFloat = toNumber (F32A.length pcmData) / toNumber width
    samplesPerBin      = ceil  samplesPerBinFloat
    binOffset          = floor samplesPerBinFloat

toString :: Waveform -> String
toString (Waveform histogram height) =
  joinWith "\n" $ Array.range 0 height <#> \heightIndex ->
    let currentHeight = height - heightIndex
    in  fromCharArray $ histogram <#> \histEntry ->
        if histEntry >= currentHeight then '#' else ' '
