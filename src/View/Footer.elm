module View.Footer exposing (view)

import Html as H
import Html.Attributes as HA


view : H.Html msg
view =
    H.footer []
        [ H.div
            [ HA.class "container" ]
            [ H.a
                [ HA.class "logo-font"
                , HA.href "./home.html"
                ]
                [ H.text "conduit" ]
            , H.span
                [ HA.class "attribution" ]
                [ H.text "An interactive learning project from "
                , H.a
                    [ HA.href "https://thinkster.io" ]
                    [ H.text "Thinkster" ]
                , H.text ". Code & design licensed under MIT."
                ]
            ]
        ]
