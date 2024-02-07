module Data.Offset exposing (Offset, fromInt, toInt, zero)


type Offset
    = Offset Int


zero : Offset
zero =
    Offset 0


fromInt : Int -> Offset
fromInt n =
    if n > 0 then
        Offset n

    else
        zero


toInt : Offset -> Int
toInt (Offset n) =
    n
