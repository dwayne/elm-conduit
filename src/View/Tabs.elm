module View.Tabs exposing (Tab, Tabs, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE


type alias Tabs tab msg =
    { name : String
    , tabs : List (Tab tab)
    , activeTab : tab
    , isDisabled : Bool
    , onSwitch : tab -> msg
    }


type alias Tab tab =
    { id : tab
    , title : String
    }


view : Tabs tab msg -> H.Html msg
view { name, tabs, activeTab, isDisabled, onSwitch } =
    let
        className =
            name ++ "-toggle"

        viewTabs =
            List.map (viewTab activeTab isDisabled onSwitch) tabs
    in
    H.div
        [ HA.class className ]
        [ H.ul
            [ HA.class "nav nav-pills outline-active" ]
            viewTabs
        ]


viewTab : tab -> Bool -> (tab -> msg) -> Tab tab -> H.Html msg
viewTab activeTab isDisabled onSwitch { id, title } =
    let
        baseAttrs =
            [ HA.class "nav-link"
            ]

        extraAttrs =
            if id == activeTab then
                [ HA.class "active"
                ]

            else
                [ if isDisabled then
                    HA.disabled True

                  else
                    HE.onClick (onSwitch id)
                ]

        attrs =
            baseAttrs ++ extraAttrs
    in
    H.li
        [ HA.class "nav-item" ]
        [ H.button attrs [ H.text title ]
        ]
