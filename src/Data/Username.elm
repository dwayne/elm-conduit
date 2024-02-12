module Data.Username exposing
    ( Username
    , decoder
    , encode
    , fromString
    , toString
    )

import Json.Decode as JD
import Json.Encode as JE
import Lib.NonEmptyString as NonEmptyString exposing (NonEmptyString)


type Username
    = Username NonEmptyString


fromString : String -> Maybe Username
fromString =
    Maybe.map Username << NonEmptyString.fromString


decoder : JD.Decoder Username
decoder =
    JD.map Username NonEmptyString.decoder


encode : Username -> JE.Value
encode (Username username) =
    NonEmptyString.encode username


toString : Username -> String
toString (Username username) =
    NonEmptyString.toString username
