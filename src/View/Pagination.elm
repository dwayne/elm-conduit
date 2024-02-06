module View.Pagination exposing (Pagination, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Lib.Html.Attributes as HA


type alias Pagination msg =
    { totalPages : Int
    , currentPage : Int
    , onClick : Int -> msg
    }


view : Pagination msg -> H.Html msg
view { totalPages, currentPage, onClick } =
    let
        oneToPages =
            List.range 1 totalPages
    in
    H.ul [ HA.class "pagination" ] <|
        List.map
            (\page ->
                viewPageItem
                    { page = page
                    , currentPage = currentPage
                    , onClick = onClick
                    }
            )
            oneToPages


type alias PageItemOptions msg =
    { page : Int
    , currentPage : Int
    , onClick : Int -> msg
    }


viewPageItem : PageItemOptions msg -> H.Html msg
viewPageItem { page, currentPage, onClick } =
    let
        isActive =
            page == currentPage

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
