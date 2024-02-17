module Data.Token exposing
    ( Token
    , decoder
    , fromString
    , toAuthorizationHeader
    , toString
    )

import Http
import Json.Decode as JD
import Lib.NonEmptyString as NonEmptyString exposing (NonEmptyString)


type Token
    = Token NonEmptyString


fromString : String -> Maybe Token
fromString =
    --
    -- TODO: Check that the given string at least looks like a token.
    --
    Maybe.map Token << NonEmptyString.fromString


decoder : JD.Decoder Token
decoder =
    JD.map Token NonEmptyString.decoder


toAuthorizationHeader : Token -> Http.Header
toAuthorizationHeader =
    toString >> (++) "Token " >> Http.header "Authorization"


toString : Token -> String
toString (Token token) =
    NonEmptyString.toString token
