module Float32Array (
  module Data.ArrayBuffer.Types
, length
, map
, reduce
, subarray
, sum
--, mean
) where

import Data.Semiring ((+))
import Data.ArrayBuffer.Types (Float32Array)

foreign import fromArray :: Array Number -> Float32Array

foreign import toArray :: Float32Array -> Array Number

-- TODO: Number? This could be huge, no?
foreign import length :: Float32Array -> Int

foreign import map :: Float32Array -> (Number -> Number) -> Float32Array

foreign import reduce :: forall a. Float32Array -> (a -> Number -> a) -> a -> a

foreign import subarray :: Float32Array -> Int -> Int -> Float32Array

sum :: Float32Array -> Number
sum xs = reduce xs (+) 0.0
