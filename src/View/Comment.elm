module View.Comment exposing (Comment, DeleteOptions, view)

import Data.Route as Route
import Data.Timestamp as Timestamp exposing (Timestamp)
import Data.Username as Username exposing (Username)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Lib.Html.Attributes as HA
import Lib.NonEmptyString as NonEmptyString exposing (NonEmptyString)
import Time
import Url exposing (Url)


type alias Comment msg =
    { body : NonEmptyString
    , username : Username
    , imageUrl : Url
    , zone : Time.Zone
    , timestamp : Timestamp
    , maybeDelete : Maybe (DeleteOptions msg)
    }


type alias DeleteOptions msg =
    { isDisabled : Bool
    , onDelete : msg
    }


view : Comment msg -> H.Html msg
view { body, username, imageUrl, zone, timestamp, maybeDelete } =
    let
        profileUrl =
            Route.toString <| Route.Profile username
    in
    H.div
        [ HA.class "card" ]
        [ H.div
            [ HA.class "card-block" ]
            [ H.p
                [ HA.class "card-text" ]
                [ H.text <| NonEmptyString.toString body ]
            ]
        , H.div
            [ HA.class "card-footer" ]
            [ H.a
                [ HA.class "comment-author"
                , HA.href profileUrl
                ]
                [ H.img
                    [ HA.class "comment-author-img"
                    , HA.src <| Url.toString imageUrl
                    ]
                    []
                ]
            , H.text "\u{00A0}"
            , H.a
                [ HA.class "comment-author"
                , HA.href profileUrl
                ]
                [ H.text <| Username.toString username
                ]
            , H.span
                [ HA.class "date-posted" ]
                --
                -- TODO: Display the timestamp with a time as well, not just the day.
                --
                [ H.text <| Timestamp.toString zone timestamp ]
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
                        [ H.i
                            [ HA.class "ion-trash-a"
                            , HA.classList [ ( "is-disabled", isDisabled ) ]
                            ]
                            []
                        ]

                Nothing ->
                    H.text ""
            ]
        ]
