module Page.Error exposing (ViewOptions, view)

import Html as H
import Html.Attributes as HA


type alias ViewOptions =
    { title : String
    , message : String
    }


view : ViewOptions -> H.Html msg
view { title, message } =
    H.div
        [ HA.class "error-page" ]
        [ H.div
            [ HA.class "container page" ]
            [ H.div
                [ HA.class "row" ]
                [ H.div
                    [ HA.class "col-xs-12" ]
                    [ H.h1 [] [ H.text title ]
                    , H.p [] [ H.text message ]
                    ]
                ]
            ]
        ]
