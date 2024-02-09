module Data.Total exposing
    ( Total
    , decoder
    , fromInt
    , toInt
    , toString
    , zero
    )

import Json.Decode as JD


type Total
    = Total Int


zero : Total
zero =
    Total 0


fromInt : Int -> Total
fromInt =
    max 0 >> Total


decoder : JD.Decoder Total
decoder =
    JD.map fromInt JD.int


toInt : Total -> Int
toInt (Total n) =
    n


toString : Total -> String
toString =
    toInt >> String.fromInt
