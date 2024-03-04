module Data.Viewer exposing (Viewer(..), toToken)

import Data.Token exposing (Token)
import Data.User exposing (User)


type Viewer
    = Guest
    | User User


toToken : Viewer -> Maybe Token
toToken viewer =
    case viewer of
        Guest ->
            Nothing

        User { token } ->
            Just token
