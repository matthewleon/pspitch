module Main where

import ArrayBuffer (fromBuffer)
import Float32Array (Float32Array)
import Pitchfinder (detectPitchYIN)
import WavDecoder (decodeSync)
import Waveform as W
import Control.Monad.Eff (Eff, foreachE)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Array as A
import Data.Maybe (fromJust)
import Data.String.Regex (test)
import Data.String.Regex.Unsafe (unsafeRegex)
import Data.String.Regex.Flags (noFlags)
import Node.FS (FS)
import Node.FS.Sync (readdir, readFile)
import Node.Buffer (Buffer)
import Node.Path (FilePath)
import Partial.Unsafe (unsafePartial)
import Pitch (Pitch(..), pitchToNote)
import Prelude

main :: forall eff. Eff (fs :: FS, exception :: EXCEPTION, console :: CONSOLE | eff) Unit
main = do
  a1 <- readFile "octave/a1.wav"
  let leftChan = getLeftChan a1
      wavForm = W.toWaveform 160 20 leftChan
  logShow wavForm
  log $ W.toString wavForm

{-
main = flip foreachE logPitch =<< A.filter dotwav <$> readdir "octave"
  where
  logPitch path = do
    pitch <- filePitch ("octave/" <> path)
    log path *> logShow pitch *> logShow (pitchToNote pitch)
  dotwav = test $ unsafeRegex ".+\\.wav$" noFlags
-}

filePitch :: forall eff. FilePath -> Eff ( fs :: FS, exception :: EXCEPTION | eff) Pitch
filePitch = map bufferPitch <<< readFile

bufferPitch :: Buffer -> Pitch
bufferPitch = Pitch <<< detectPitchYIN <<< getLeftChan

getLeftChan :: Buffer -> Float32Array
getLeftChan buf = unsafePartial $ fromJust $
  A.head (decodeSync $ fromBuffer buf).channelData
