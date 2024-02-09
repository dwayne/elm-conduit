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
import Data.PageNumber as PageNumber exposing (PageNumber)
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


toPage : PageNumber -> Pager -> Page
toPage pageNumber (Pager { limit, maybeTotalPages }) =
    case maybeTotalPages of
        Nothing ->
            { offset = Offset.zero
            , limit = limit
            }

        Just _ ->
            { offset =
                Offset.fromInt <|
                    (PageNumber.toInt pageNumber - 1)
                        * Limit.toInt limit
            , limit = limit
            }


toTotalPages : Pager -> Total
toTotalPages (Pager { maybeTotalPages }) =
    Maybe.withDefault Total.zero maybeTotalPages
