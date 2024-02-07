module Data.Tag exposing
    ( Tag
    , decoder
    , fromString
    , toString
    )

import Json.Decode as JD
import Lib.NonEmptyString as NonEmptyString exposing (NonEmptyString)


type Tag
    = Tag NonEmptyString


fromString : String -> Maybe Tag
fromString =
    Maybe.map Tag << NonEmptyString.fromString


decoder : JD.Decoder Tag
decoder =
    JD.map Tag NonEmptyString.decoder


toString : Tag -> String
toString (Tag tag) =
    NonEmptyString.toString tag
