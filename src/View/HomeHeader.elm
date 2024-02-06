module View.HomeHeader exposing (view)

import Html as H
import Html.Attributes as HA


view : H.Html msg
view =
    H.div
        [ HA.class "banner" ]
        [ H.div
            [ HA.class "container" ]
            [ H.h1
                [ HA.class "logo-font" ]
                [ H.text "conduit" ]
            , H.p []
                [ H.text "A place to share your knowledge." ]
            ]
        ]
