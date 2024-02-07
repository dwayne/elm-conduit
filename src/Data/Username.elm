module Data.Username exposing
    ( Username
    , decoder
    , fromString
    , toString
    )

import Json.Decode as JD
import Lib.NonEmptyString as NonEmptyString exposing (NonEmptyString)


type Username
    = Username NonEmptyString


fromString : String -> Maybe Username
fromString =
    Maybe.map Username << NonEmptyString.fromString


decoder : JD.Decoder Username
decoder =
    JD.map Username NonEmptyString.decoder


toString : Username -> String
toString (Username username) =
    NonEmptyString.toString username
