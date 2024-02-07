module Data.Limit exposing (Limit, ten, toInt)


type Limit
    = Limit Int


ten : Limit
ten =
    Limit 10


toInt : Limit -> Int
toInt (Limit n) =
    n
