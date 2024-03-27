module View.Layout exposing (ViewOptions, view)

import Html as H
import Html.Attributes as HA
import View.Footer as Footer
import View.Navigation as Navigation


type alias ViewOptions msg =
    { name : String
    , role : Navigation.Role
    , maybeHeader : Maybe (H.Html msg)
    }


view : ViewOptions msg -> List (H.Html msg) -> H.Html msg
view { name, role, maybeHeader } content =
    H.div []
        [ Navigation.view { role = role }
        , H.div [ HA.class <| name ++ "-page" ] <|
            List.concat
                [ maybeHeader
                    |> Maybe.map List.singleton
                    |> Maybe.withDefault []
                , [ H.div [ HA.class "container page" ] content ]
                ]
        , Footer.view
        ]
