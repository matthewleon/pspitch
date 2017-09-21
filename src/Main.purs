module Main where

import ArrayBuffer (fromBuffer)
import Pitchfinder (detectPitchYIN)
import WavDecoder (decodeSync)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Array as A
import Data.Maybe (fromJust)
import Node.FS (FS)
import Node.FS.Sync (readFile)
import Partial.Unsafe (unsafePartial)
import Prelude

main :: forall eff. Eff ( fs :: FS, exception :: EXCEPTION, console :: CONSOLE | eff) Unit
main = do
  log "reading audio data"
  arrayBuf <- fromBuffer <$> readFile "octave/68437__pinkyfinger__piano-a.wav"
  log "decoding WAV"
  let audioData = decodeSync arrayBuf
      leftChannelData = unsafePartial $ fromJust (A.head audioData.channelData)
  log "detecting pitch"
  let pitch = detectPitchYIN leftChannelData
  logShow pitch
