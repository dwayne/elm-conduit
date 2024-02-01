module View.Pagination exposing (Pagination, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE


type alias Pagination msg =
    { pages : Int
    , current : Int
    , onClick : Int -> msg
    }


view : Pagination msg -> H.Html msg
view { pages, current, onClick } =
    let
        oneToPages =
            List.range 1 pages
    in
    H.ul [ HA.class "pagination" ] <|
        List.map
            (\page ->
                viewPageItem
                    { page = page
                    , current = current
                    , onClick = onClick
                    }
            )
            oneToPages


type alias PageItemOptions msg =
    { page : Int
    , current : Int
    , onClick : Int -> msg
    }


viewPageItem : PageItemOptions msg -> H.Html msg
viewPageItem { page, current, onClick } =
    let
        isActive =
            page == current

        buttonAttrs =
            List.filterMap identity <|
                [ Just <| HA.class "page-link"
                , if isActive then
                    Nothing

                  else
                    Just <| HE.onClick (onClick page)
                ]
    in
    H.li
        [ HA.class "page-item"
        , HA.classList [ ( "active", isActive ) ]
        ]
        [ H.button buttonAttrs
            [ H.text <| String.fromInt page ]
        ]
