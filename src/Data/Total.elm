module Data.Total exposing
    ( Total
    , decoder
    , fromInt
    , toInt
    , zero
    )

import Json.Decode as JD


type Total
    = Total Int


zero : Total
zero =
    Total 0


fromInt : Int -> Total
fromInt n =
    if n > 0 then
        Total n

    else
        zero


decoder : JD.Decoder Total
decoder =
    JD.map fromInt JD.int


toInt : Total -> Int
toInt (Total n) =
    n
