module Data.PageNumber exposing (PageNumber, fromInt, one, toInt, toString)


type PageNumber
    = PageNumber Int


one : PageNumber
one =
    PageNumber 1


fromInt : Int -> PageNumber
fromInt =
    max 1 >> PageNumber


toInt : PageNumber -> Int
toInt (PageNumber n) =
    n


toString : PageNumber -> String
toString =
    toInt >> String.fromInt
