module Data.Timestamp exposing
    ( Timestamp
    , decoder
    , fromString
    , toString
    )

import Date
import Iso8601
import Json.Decode as JD
import Time


type Timestamp
    = Timestamp Time.Posix


fromString : String -> Maybe Timestamp
fromString =
    Iso8601.toTime >> Result.toMaybe >> Maybe.map Timestamp


decoder : JD.Decoder Timestamp
decoder =
    JD.map Timestamp Iso8601.decoder


toString : Time.Zone -> Timestamp -> String
toString zone (Timestamp posix) =
    posix
        |> Date.fromPosix zone
        |> Date.format "MMMM ddd, y"
