module Lib.String exposing (pluralize)


pluralize : Int -> { singular : String, plural : String } -> String
pluralize n { singular, plural } =
    if n == 1 then
        singular

    else
        plural
