module Pitch (Pitch(..), Note, pitchToNote) where

import Prelude

import Data.Array (unsafeIndex)
import Data.Array as Array
import Data.Enum (class BoundedEnum, class Enum, Cardinality(..), defaultPred, defaultSucc, fromEnum, toEnum, enumFromTo)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..), fromJust)
import Data.Map (Map)
import Data.Map as Map
import Data.Tuple (Tuple(..))
import Partial.Unsafe (unsafePartial)

data Key = A | As | B | C | Cs | D | Ds | E | F | Fs | G | Gs
derive instance genericKey :: Generic Key _
derive instance eqKey   :: Eq Key
instance showKey :: Show Key
  where show = genericShow

newtype Octave = Octave Int
derive newtype instance showOctave :: Show Octave
derive newtype instance eqOctave   :: Eq Octave
derive newtype instance ordOctave  :: Ord Octave

mkOctave :: Int -> Maybe Octave
mkOctave i
  | i < 0     = Nothing
  | i > 8     = Nothing
  | otherwise = Just $ Octave i

data Note = Note Key Octave
derive instance genericNote :: Generic Note _
derive instance eqNote      :: Eq Note
instance showNote           :: Show Note
  where show = genericShow
instance ordNote            :: Ord Note
  where compare = comparing fromEnum
instance enumNote           :: Enum Note
  where
  pred = defaultPred toEnum fromEnum
  succ = defaultSucc toEnum fromEnum
instance boundedNote        :: Bounded Note
  where
  bottom = Note A (Octave 0)
  top    = Note C (Octave 8)
instance boundedEnumNote    :: BoundedEnum Note
  where
  cardinality = Cardinality 88
  fromEnum (Note k (Octave i)) = 3 + 12 * (i - 1) + kval k
    where
    kval C  = 0
    kval Cs = 1
    kval D  = 2
    kval Ds = 3
    kval E  = 4
    kval F  = 5
    kval Fs = 6
    kval G  = 7
    kval Gs = 8
    kval A  = 9
    kval As = 10
    kval B  = 11
  toEnum i = do
    note <- toNote $ i `mod` 12
    octave <- mkOctave $ i / 12
    mkNote note octave
    where
    toNote 0  = Just C
    toNote 1  = Just Cs
    toNote 2  = Just D
    toNote 3  = Just Ds
    toNote 4  = Just E
    toNote 5  = Just F
    toNote 6  = Just Fs
    toNote 7  = Just G
    toNote 8  = Just Gs
    toNote 9  = Just A
    toNote 10 = Just As
    toNote 11 = Just B
    toNote _  = Nothing

mkNote :: Key -> Octave -> Maybe Note
mkNote A  o@(Octave 0) = Just $ Note A  o
mkNote As o@(Octave 0) = Just $ Note As o
mkNote B  o@(Octave 0) = Just $ Note B  o
mkNote _    (Octave 0) = Nothing
mkNote C  o@(Octave 8) = Just $ Note C  o
mkNote _    (Octave 8) = Nothing
mkNote k  o            = Just $ Note k  o

newtype Pitch = Pitch Number
derive newtype instance showPitch      :: Show Pitch
derive newtype instance eqPitch        :: Eq Pitch
derive newtype instance ordPitch       :: Ord Pitch
derive newtype instance semiringPitch  :: Semiring Pitch
derive newtype instance ringPitch      :: Ring Pitch

notePitches :: Map Note Pitch
notePitches = Map.fromFoldable $ Array.zipWith Tuple notes pitches

pitchNotes :: Map Pitch Note
pitchNotes = Map.fromFoldable $ Array.zipWith Tuple pitches notes

-- TODO: use logn binary search instead of n linear search
pitchToNote :: Pitch -> Note
pitchToNote p
  | p >= unsafeLookup top notePitches    = top
  | p <= unsafeLookup bottom notePitches = bottom
  | otherwise                            = go 1 `unsafeLookup` pitchNotes
      where
      go i = if p <= index pitches i
             then
               if (p - (pitches `index` (i - 1))) <
                 ((index pitches i) - p)
               then index pitches $ i - 1
               else index pitches i
             else go $ i + 1
        where index arr i' = unsafePartial $ unsafeIndex arr i'

unsafeLookup :: forall k v. Ord k => k -> Map k v -> v
unsafeLookup k v = unsafePartial $ fromJust $ Map.lookup k v

notes :: Array Note
notes = enumFromTo bottom top

pitches :: Array Pitch
pitches = Pitch <$> [
    27.5
  , 29.1352
  , 30.8677
  , 32.7032
  , 34.6478
  , 36.7081
  , 38.8909
  , 41.2034
  , 43.6535
  , 46.2493
  , 48.9994
  , 51.9131
  , 55.0
  , 58.2705
  , 61.7354
  , 65.4064
  , 69.2957
  , 73.4162
  , 77.7817
  , 82.4069
  , 87.3071
  , 92.4986
  , 97.9989
  , 103.826
  , 110.000
  , 116.541
  , 123.471
  , 130.813
  , 138.591
  , 146.832
  , 155.563
  , 164.814
  , 174.614
  , 184.997
  , 195.998
  , 207.652
  , 220.000
  , 233.082
  , 246.942
  , 261.626
  , 277.183
  , 293.665
  , 311.127
  , 329.628
  , 349.228
  , 369.994
  , 391.995
  , 415.305
  , 440.000
  , 466.164
  , 493.883
  , 523.251
  , 554.365
  , 587.330
  , 622.254
  , 659.255
  , 698.456
  , 739.989
  , 783.991
  , 830.609
  , 880.000
  , 932.328
  , 987.767
  , 1046.50
  , 1108.73
  , 1174.66
  , 1244.51
  , 1318.51
  , 1396.91
  , 1479.98
  , 1567.98
  , 1661.22
  , 1760.00
  , 1864.66
  , 1975.53
  , 2093.00
  , 2217.46
  , 2349.32
  , 2489.02
  , 2637.02
  , 2793.83
  , 2959.96
  , 3135.96
  , 3322.44
  , 3520.00
  , 3729.31
  , 3951.07
  , 4186.01
]
