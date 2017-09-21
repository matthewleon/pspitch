module WavDecoder (AudioData, decodeSync) where

import Data.ArrayBuffer.Types (ArrayBuffer, Float32Array)

type AudioData = {
  sampleRate :: Number
, channelData :: Array Float32Array
}

foreign import decodeSync :: ArrayBuffer -> AudioData
