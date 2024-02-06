module View.Sidebar exposing (Sidebar(..), TagListOptions, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Lib.Html.Attributes as HA


type Sidebar msg
    = Loading
    | Tags (TagListOptions msg)
    | Error String


type alias TagListOptions msg =
    { tags : List String
    , activeTag : String
    , onClick : String -> msg
    }


view : Sidebar msg -> H.Html msg
view sidebar =
    H.div
        [ HA.class "sidebar" ]
        [ H.p [] [ H.text "Popular Tags" ]
        , viewTagList sidebar
        ]


viewTagList : Sidebar msg -> H.Html msg
viewTagList sidebar =
    H.div [ HA.class "tag-list" ] <|
        case sidebar of
            Loading ->
                [ H.text "Loading tags..." ]

            Tags { tags, activeTag, onClick } ->
                List.map
                    (\tag ->
                        let
                            attrs =
                                HA.attrList
                                    [ HA.class "tag-pill tag-default" ]
                                    [ ( tag /= activeTag, HE.onClick (onClick tag) )
                                    ]
                        in
                        H.button attrs [ H.text tag ]
                    )
                    tags

            Error message ->
                [ H.text message ]
