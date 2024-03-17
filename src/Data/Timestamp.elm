module Data.Timestamp exposing
    ( Timestamp
    , compare
    , decoder
    , fromString
    , toDayAndTimeString
    , toDayString
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


toDayAndTimeString : Time.Zone -> Timestamp -> String
toDayAndTimeString zone timestamp =
    toDayString zone timestamp ++ " at " ++ toTimeString zone timestamp


toDayString : Time.Zone -> Timestamp -> String
toDayString zone (Timestamp posix) =
    posix
        |> Date.fromPosix zone
        |> Date.format "MMMM ddd, y"


toTimeString : Time.Zone -> Timestamp -> String
toTimeString zone (Timestamp posix) =
    --
    -- NOTE: This function is a good candidate for unit tests.
    --
    let
        hour24 =
            Time.toHour zone posix

        --
        -- Based on https://www.timeanddate.com/time/am-and-pm.html.
        --
        ( hour12, period ) =
            if hour24 < 12 then
                ( if hour24 == 0 then
                    12

                  else
                    hour24
                , "am"
                )

            else
                ( if hour24 == 12 then
                    12

                  else
                    hour24 - 12
                , "pm"
                )

        minute =
            Time.toMinute zone posix
    in
    String.concat
        [ String.fromInt hour12
        , ":"
        , String.fromInt minute
            |> String.padLeft 2 '0'
        , " "
        , period
        ]
