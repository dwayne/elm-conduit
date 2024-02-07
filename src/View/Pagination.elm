module View.Pagination exposing (Pagination, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Lib.Html.Attributes as HA


type alias Pagination msg =
    { totalPages : Int
    , currentPageNumber : Int
    , onClick : Int -> msg
    }


view : Pagination msg -> H.Html msg
view { totalPages, currentPageNumber, onClick } =
    if totalPages <= 1 || currentPageNumber < 1 then
        H.text ""

    else
        let
            oneToPages =
                List.range 1 totalPages
        in
        H.ul [ HA.class "pagination" ] <|
            List.map
                (\page ->
                    viewPageItem
                        { page = page
                        , currentPageNumber = currentPageNumber
                        , onClick = onClick
                        }
                )
                oneToPages


type alias PageItemOptions msg =
    { page : Int
    , currentPageNumber : Int
    , onClick : Int -> msg
    }


viewPageItem : PageItemOptions msg -> H.Html msg
viewPageItem { page, currentPageNumber, onClick } =
    let
        isActive =
            page == currentPageNumber

        buttonAttrs =
            HA.attrList
                [ HA.class "page-link" ]
                [ ( not isActive, HE.onClick (onClick page) )
                ]
    in
    H.li
        [ HA.class "page-item"
        , HA.classList [ ( "active", isActive ) ]
        ]
        [ H.button buttonAttrs
            [ H.text <| String.fromInt page ]
        ]
