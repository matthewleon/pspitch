module Pitchfinder (detectPitchYIN) where

import Data.ArrayBuffer.Types (Float32Array)

-- TODO: support options
foreign import detectPitchYIN :: Float32Array -> Number
