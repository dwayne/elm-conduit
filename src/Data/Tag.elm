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
    = Tag String


fromString : String -> Maybe Tag
fromString =
    Maybe.map (Tag << NonEmptyString.toString) << NonEmptyString.fromString


decoder : JD.Decoder Tag
decoder =
    --
    -- Unfortunately the backend allows the tag to be blank.
    --
    JD.map Tag JD.string


encode : Tag -> JE.Value
encode =
    JE.string << toString


toString : Tag -> String
toString (Tag tag) =
    tag
