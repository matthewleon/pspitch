module Float32Array (
  module Data.ArrayBuffer.Types
, length
, map
, reduce
, subarray
, sum
, mean
) where

import Data.ArrayBuffer.Types (Float32Array)

-- TODO: Number? This could be huge, no?
foreign import length :: Float32Array -> Int

foreign import map :: Float32Array -> (Number -> Number) -> Float32Array

 foreign import reduce :: Float32Array -> (a -> Number -> a) ->

foreign import subarray :: Float32Array -> Int -> Int -> Float32Array
