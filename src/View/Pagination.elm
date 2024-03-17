module View.Pagination exposing (ViewOptions, view)

import Data.PageNumber as PageNumber exposing (PageNumber)
import Data.Total as Total exposing (Total)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Lib.Html.Attributes as HA


type alias ViewOptions msg =
    { totalPages : Total
    , currentPageNumber : PageNumber
    , onChangePageNumber : PageNumber -> msg
    }


view : ViewOptions msg -> H.Html msg
view options =
    let
        n =
            Total.toInt options.totalPages
    in
    if n <= 1 then
        H.text ""

    else
        let
            viewPageItems =
                n
                    |> List.range 1
                    |> List.map
                        (\i ->
                            viewPageItem
                                { pageNumber = PageNumber.fromInt i
                                , currentPageNumber = options.currentPageNumber
                                , onChangePageNumber = options.onChangePageNumber
                                }
                        )
        in
        H.ul [ HA.class "pagination" ] viewPageItems


type alias PageItemOptions msg =
    { pageNumber : PageNumber
    , currentPageNumber : PageNumber
    , onChangePageNumber : PageNumber -> msg
    }


viewPageItem : PageItemOptions msg -> H.Html msg
viewPageItem { pageNumber, currentPageNumber, onChangePageNumber } =
    let
        isActive =
            pageNumber == currentPageNumber

        buttonAttrs =
            HA.attrList
                [ HA.class "page-link" ]
                [ ( HE.onClick <| onChangePageNumber pageNumber
                  , not isActive
                  )
                ]
    in
    H.li
        [ HA.class "page-item"
        , HA.classList [ ( "active", isActive ) ]
        ]
        [ H.button buttonAttrs
            [ H.text <| PageNumber.toString pageNumber ]
        ]
