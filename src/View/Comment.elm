module View.Comment exposing (Comment, DeleteOptions, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Lib.Html.Attributes as HA


type alias Comment msg =
    { comment : String
    , name : String
    , imageUrl : String
    , date : String
    , maybeDelete : Maybe (DeleteOptions msg)
    }


type alias DeleteOptions msg =
    { isDisabled : Bool
    , onDelete : msg
    }


view : Comment msg -> H.Html msg
view { comment, name, imageUrl, date, maybeDelete } =
    H.div
        [ HA.class "card" ]
        [ H.div
            [ HA.class "card-block" ]
            [ H.p
                [ HA.class "card-text" ]
                [ H.text comment ]
            ]
        , H.div
            [ HA.class "card-footer" ]
            [ H.a
                [ HA.class "comment-author"
                , HA.href "./profile.html"
                ]
                [ H.img
                    [ HA.class "comment-author-img"
                    , HA.src imageUrl
                    ]
                    []
                ]
            , H.text "\u{00A0}"
            , H.a
                [ HA.class "comment-author"
                , HA.href "./profile.html"
                ]
                [ H.text name
                ]
            , H.span
                [ HA.class "date-posted" ]
                [ H.text date ]
            , case maybeDelete of
                Just { isDisabled, onDelete } ->
                    let
                        isEnabled =
                            not isDisabled

                        attrs =
                            HA.attrList
                                [ HA.class "mod-options" ]
                                [ ( isEnabled, HE.onClick onDelete )
                                ]
                    in
                    H.span attrs
                        [ H.i [ HA.class "ion-trash-a" ] []
                        ]

                Nothing ->
                    H.text ""
            ]
        ]
