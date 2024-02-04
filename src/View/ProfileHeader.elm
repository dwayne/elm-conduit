module View.ProfileHeader exposing
    ( ProfileHeader
    , Role(..)
    , view
    )

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import View.FollowButton as FollowButton exposing (FollowButton)


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
                            FollowButton.view username followButton

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
