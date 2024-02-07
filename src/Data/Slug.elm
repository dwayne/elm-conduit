module Data.Slug exposing
    ( Slug
    , decoder
    , fromString
    , toString
    )

import Json.Decode as JD
import Lib.NonEmptyString as NonEmptyString exposing (NonEmptyString)


type Slug
    = Slug NonEmptyString


fromString : String -> Maybe Slug
fromString =
    Maybe.map Slug << NonEmptyString.fromString


decoder : JD.Decoder Slug
decoder =
    JD.map Slug NonEmptyString.decoder


toString : Slug -> String
toString (Slug slug) =
    NonEmptyString.toString slug
