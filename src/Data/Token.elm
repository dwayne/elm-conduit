module Data.Token exposing
    ( Token
    , decoder
    , toAuthorizationHeader
    , toString
    )

import Http
import Json.Decode as JD
import Lib.NonEmptyString as NonEmptyString exposing (NonEmptyString)


type Token
    = Token NonEmptyString


decoder : JD.Decoder Token
decoder =
    JD.map Token NonEmptyString.decoder


toAuthorizationHeader : Token -> Http.Header
toAuthorizationHeader =
    toString >> (++) "Token " >> Http.header "Authorization"


toString : Token -> String
toString (Token token) =
    NonEmptyString.toString token
