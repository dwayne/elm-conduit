module View.Toggle exposing (Tab, Toggle, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE


type alias Toggle a msg =
    { name : String
    , tabs : List (Tab a)
    , active : a
    , onClick : a -> msg
    }


type alias Tab a =
    { id : a
    , title : String
    }


view : Toggle a msg -> H.Html msg
view { name, tabs, active, onClick } =
    let
        className =
            name ++ "-toggle"

        viewTabs =
            List.map (viewTab active onClick) tabs
    in
    H.div
        [ HA.class className ]
        [ H.ul
            [ HA.class "nav nav-pills outline-active" ]
            viewTabs
        ]


viewTab : a -> (a -> msg) -> Tab a -> H.Html msg
viewTab active onClick { id, title } =
    let
        baseAttrs =
            [ HA.class "nav-link"
            ]

        extraAttrs =
            if active == id then
                [ HA.class "active"
                ]

            else
                [ HE.onClick (onClick id)
                ]

        attrs =
            baseAttrs ++ extraAttrs
    in
    H.li
        [ HA.class "nav-item" ]
        [ H.button attrs [ H.text title ]
        ]
