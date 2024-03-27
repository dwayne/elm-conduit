module View.Column exposing (Size(..), viewDouble, viewSingle)

import Html as H
import Html.Attributes as HA


type Size
    = Large
    | Medium
    | Small
    | ExtraSmall


viewSingle : Size -> List (H.Html msg) -> H.Html msg
viewSingle size column =
    let
        classNames =
            case size of
                Large ->
                    "col-xs-12"

                Medium ->
                    "col-md-10 offset-md-1 col-xs-12"

                Small ->
                    "col-md-8 offset-md-2 col-xs-12"

                ExtraSmall ->
                    "col-md-6 offset-md-3 col-xs-12"
    in
    H.div
        [ HA.class "row" ]
        [ H.div [ HA.class classNames ] column
        ]


viewDouble :
    { left : List (H.Html msg)
    , right : List (H.Html msg)
    }
    -> H.Html msg
viewDouble { left, right } =
    H.div
        [ HA.class "row" ]
        [ H.div [ HA.class "col-md-9" ] left
        , H.div [ HA.class "col-md-3" ] right
        ]
