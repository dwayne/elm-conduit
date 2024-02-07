module Data.Pager exposing
    ( Page
    , Pager
    , new
    , setTotalPages
    , toPage
    , toTotalPages
    )

import Data.Limit as Limit exposing (Limit)
import Data.Offset as Offset exposing (Offset)
import Data.Total as Total exposing (Total)


type Pager
    = Pager
        { limit : Limit
        , maybeTotalPages : Maybe Total
        }


new : Pager
new =
    Pager
        { limit = Limit.ten
        , maybeTotalPages = Nothing
        }


setTotalPages : Total -> Pager -> Pager
setTotalPages totalItems (Pager pager) =
    let
        totalPages =
            Total.fromInt <|
                total
                    // limit
                    + extra

        total =
            Total.toInt totalItems

        limit =
            Limit.toInt pager.limit

        extra =
            if modBy limit total == 0 then
                0

            else
                1
    in
    Pager { pager | maybeTotalPages = Just totalPages }


type alias Page =
    { offset : Offset
    , limit : Limit
    }


toPage : Int -> Pager -> Page
toPage i (Pager { limit, maybeTotalPages }) =
    case maybeTotalPages of
        Nothing ->
            { offset = Offset.zero
            , limit = limit
            }

        Just _ ->
            let
                n =
                    max 1 i
            in
            { offset = Offset.fromInt <| (n - 1) * Limit.toInt limit
            , limit = limit
            }


toTotalPages : Pager -> Total
toTotalPages (Pager { maybeTotalPages }) =
    Maybe.withDefault Total.zero maybeTotalPages
