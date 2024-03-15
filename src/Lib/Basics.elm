module Lib.Basics exposing (reverseOrder)


reverseOrder : Order -> Order
reverseOrder order =
    case order of
        LT ->
            GT

        EQ ->
            EQ

        GT ->
            LT
