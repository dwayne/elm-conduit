module View.ProfileHeader exposing (GuestOptions, Role(..), ViewOptions, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import View.FollowButton as FollowButton exposing (FollowButton)


type alias ViewOptions msg =
    { name : String
    , imageUrl : String
    , bio : String
    , role : Role msg
    }


type Role msg
    = Guest (GuestOptions msg)
    | Owner


type alias GuestOptions msg =
    { isFollowed : Bool
    , isDisabled : Bool
    , onFollow : msg
    , onUnfollow : msg
    }


view : ViewOptions msg -> H.Html msg
view { name, imageUrl, bio, role } =
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
                        , HA.src imageUrl
                        ]
                        []
                    , H.h4 [] [ H.text name ]
                    , H.p [] [ H.text bio ]
                    , case role of
                        Guest { isFollowed, isDisabled, onFollow, onUnfollow } ->
                            FollowButton.view
                                { name = name
                                , isFollowed = isFollowed
                                , maybeTotalFollowers = Nothing
                                , isDisabled = isDisabled
                                , onFollow = onFollow
                                , onUnfollow = onUnfollow
                                }

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
