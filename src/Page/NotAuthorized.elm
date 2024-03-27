module Page.NotAuthorized exposing (view)

import Data.Route as Route
import Html as H
import Html.Attributes as HA
import View.Column as Column
import View.Layout as Layout
import View.Navigation as Navigation


view : H.Html msg
view =
    Layout.view
        { name = "not-authorized-page"
        , role = Navigation.guest
        , maybeHeader = Nothing
        }
        [ Column.viewSingle Column.Large
            [ H.p []
                [ H.text "Please "
                , H.a
                    [ HA.href <| Route.toString Route.Login ]
                    [ H.text "Sign in" ]
                , H.text " or "
                , H.a
                    [ HA.href <| Route.toString Route.Register ]
                    [ H.text "Sign up" ]
                , H.text " to view this page."
                ]
            ]
        ]
