module Data.Viewer exposing (Viewer(..))

import Data.User exposing (User)


type Viewer
    = Guest
    | User User
