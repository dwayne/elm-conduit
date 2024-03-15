module Data.Timestamp exposing
    ( Timestamp
    , compare
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


compare : Timestamp -> Timestamp -> Order
compare (Timestamp posix1) (Timestamp posix2) =
    let
        millis1 =
            Time.posixToMillis posix1

        millis2 =
            Time.posixToMillis posix2
    in
    Basics.compare millis1 millis2


toString : Time.Zone -> Timestamp -> String
toString zone (Timestamp posix) =
    posix
        |> Date.fromPosix zone
        |> Date.format "MMMM ddd, y"
