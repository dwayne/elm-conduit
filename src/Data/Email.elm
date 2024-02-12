module Data.Email exposing
    ( Email
    , decoder
    , encode
    , fromString
    , toString
    )

import Json.Decode as JD
import Json.Encode as JE
import Lib.NonEmptyString as NonEmptyString exposing (NonEmptyString)


type Email
    = Email NonEmptyString


fromString : String -> Maybe Email
fromString =
    --
    -- TODO: Check that the given string at least looks like an email.
    --
    Maybe.map Email << NonEmptyString.fromString


decoder : JD.Decoder Email
decoder =
    JD.map Email NonEmptyString.decoder


encode : Email -> JE.Value
encode (Email email) =
    NonEmptyString.encode email


toString : Email -> String
toString (Email email) =
    NonEmptyString.toString email
