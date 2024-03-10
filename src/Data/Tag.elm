module Data.Tag exposing
    ( Tag
    , decoder
    , encode
    , fromString
    , toString
    )

import Json.Decode as JD
import Json.Encode as JE
import Lib.NonEmptyString as NonEmptyString exposing (NonEmptyString)


type Tag
    = Tag NonEmptyString


fromString : String -> Maybe Tag
fromString =
    Maybe.map Tag << NonEmptyString.fromString


decoder : JD.Decoder Tag
decoder =
    JD.map Tag NonEmptyString.decoder


encode : Tag -> JE.Value
encode (Tag tag) =
    NonEmptyString.encode tag


toString : Tag -> String
toString (Tag tag) =
    NonEmptyString.toString tag
