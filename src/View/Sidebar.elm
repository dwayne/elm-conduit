module View.Sidebar exposing (TagsOptions, ViewOptions(..), view)

import Data.Tag as Tag exposing (Tag)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Lib.Html.Attributes as HA


type ViewOptions msg
    = Loading
    | Tags (TagsOptions msg)
    | Error String


type alias TagsOptions msg =
    { tags : List Tag
    , activeTag : Maybe Tag
    , onClick : Tag -> msg
    }


view : ViewOptions msg -> H.Html msg
view options =
    H.div
        [ HA.class "sidebar" ]
        [ H.p [] [ H.text "Popular Tags" ]
        , H.div [ HA.class "tag-list" ] <|
            case options of
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
        ]
