module Data.Limit exposing (Limit, five, ten, toInt)


type Limit
    = Limit Int


five : Limit
five =
    Limit 5


ten : Limit
ten =
    Limit 10


toInt : Limit -> Int
toInt (Limit n) =
    n
