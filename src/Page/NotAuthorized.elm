module Page.NotAuthorized exposing (view)

import Data.Route as Route
import Html as H
import Html.Attributes as HA
import View.Footer as Footer
import View.Navigation as Navigation


view : H.Html msg
view =
    H.div []
        [ Navigation.view { role = Navigation.guest }
        , H.div
            [ HA.class "container page" ]
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
        , Footer.view
        ]
