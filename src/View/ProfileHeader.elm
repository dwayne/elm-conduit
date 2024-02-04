module View.ProfileHeader exposing
    ( FollowButton(..)
    , FollowOptions
    , ProfileHeader
    , Role(..)
    , UnfollowOptions
    , view
    )

import Html as H
import Html.Attributes as HA
import Html.Events as HE


type alias ProfileHeader msg =
    { username : String
    , imageSrc : String
    , bio : String
    , role : Role msg
    }


type Role msg
    = Guest (FollowButton msg)
    | Owner


view : ProfileHeader msg -> H.Html msg
view { username, imageSrc, bio, role } =
    H.div
        [ HA.class "user-info" ]
        [ H.div
            [ HA.class "container" ]
            [ H.div
                [ HA.class "row" ]
                [ H.div
                    [ HA.class "col-xs-12 col-md-10 offset-md-1" ]
                    [ H.img
                        [ HA.class "user-img"
                        , HA.src imageSrc
                        ]
                        []
                    , H.h4 [] [ H.text username ]
                    , H.p [] [ H.text bio ]
                    , case role of
                        Guest followButton ->
                            viewFollowButton username followButton

                        Owner ->
                            H.a
                                [ HA.class "btn btn-sm btn-outline-secondary action-btn"
                                , HA.href "./settings.html"
                                ]
                                [ H.i
                                    [ HA.class "ion-gear-a" ]
                                    []
                                , H.text "\u{00A0} Edit Profile Settings"
                                ]
                    ]
                ]
            ]
        ]


type FollowButton msg
    = Follow (FollowOptions msg)
    | Unfollow (UnfollowOptions msg)


type alias FollowOptions msg =
    { isDisabled : Bool
    , onFollow : String -> msg
    }


type alias UnfollowOptions msg =
    { isDisabled : Bool
    , onUnfollow : String -> msg
    }


viewFollowButton : String -> FollowButton msg -> H.Html msg
viewFollowButton username followButton =
    case followButton of
        Follow { isDisabled, onFollow } ->
            H.button
                [ HA.class "btn btn-sm action-btn btn-outline-secondary"
                , if isDisabled then
                    HA.disabled True

                  else
                    HE.onClick (onFollow username)
                ]
                [ H.i
                    [ HA.class "ion-plus-round" ]
                    []
                , H.text <| "\u{00A0} Follow " ++ username
                ]

        Unfollow { isDisabled, onUnfollow } ->
            H.button
                [ HA.class "btn btn-sm action-btn btn-secondary"
                , if isDisabled then
                    HA.disabled True

                  else
                    HE.onClick (onUnfollow username)
                ]
                [ H.i
                    [ HA.class "ion-minus-round" ]
                    []
                , H.text <| "\u{00A0} Unfollow " ++ username
                ]
