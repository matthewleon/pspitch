module Pitch where

import Prelude

import Data.Enum (class BoundedEnum, class Enum, Cardinality(..), defaultPred, defaultSucc, fromEnum, toEnum)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..))

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

--notePitches :: Map Note Pitch

