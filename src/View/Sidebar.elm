module View.Sidebar exposing (Status(..), TagsOptions, ViewOptions, view)

import Data.Tag as Tag exposing (Tag)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Lib.Html.Attributes as HA


type alias ViewOptions msg =
    { status : Status msg
    }


type Status msg
    = Loading
    | Tags (TagsOptions msg)
    | Error String


type alias TagsOptions msg =
    { tags : List Tag
    , activeTag : Maybe Tag
    , onClick : Tag -> msg
    }


view : ViewOptions msg -> H.Html msg
view { status } =
    H.div
        [ HA.class "sidebar" ]
        [ H.p [] [ H.text "Popular Tags" ]
        , viewTagList status
        ]


viewTagList : Status msg -> H.Html msg
viewTagList status =
    H.div [ HA.class "tag-list" ] <|
        case status of
            Loading ->
                [ H.text "Loading tags..." ]

            Tags { tags, activeTag, onClick } ->
                List.map
                    (\tag ->
                        let
                            attrs =
                                HA.attrList
                                    [ HA.class "tag-pill tag-default" ]
                                    [ ( HE.onClick <| onClick tag
                                      , Just tag /= activeTag
                                      )
                                    ]
                        in
                        H.button attrs [ H.text <| Tag.toString tag ]
                    )
                    tags

            Error message ->
                [ H.text message ]
