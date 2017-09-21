module ArrayBuffer (fromBuffer) where

import Data.ArrayBuffer.Types (ArrayBuffer)
import Node.Buffer (Buffer)

foreign import fromBuffer :: Buffer -> ArrayBuffer
