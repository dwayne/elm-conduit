module View.ArticleActionsForGuest exposing (view)

import Data.Route as Route
import Html as H
import Html.Attributes as HA


view : H.Html msg
view =
    H.div
        [ HA.class "article-actions" ]
        [ H.p []
            [ H.a
                [ HA.href <| Route.toString Route.Login ]
                [ H.text "Sign in" ]
            , H.text " or "
            , H.a
                [ HA.href <| Route.toString Route.Register ]
                [ H.text "Sign up" ]
            , H.text " to add comments on this article."
            ]
        ]
