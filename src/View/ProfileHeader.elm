module View.ProfileHeader exposing (Role(..), UserOptions, ViewOptions, view)

import Data.Route as Route
import Data.Username as Username exposing (Username)
import Html as H
import Html.Attributes as HA
import Url exposing (Url)
import View.FollowButton as FollowButton


type alias ViewOptions msg =
    { username : Username
    , imageUrl : Url
    , bio : String
    , role : Role msg
    }


type Role msg
    = Guest
    | User (UserOptions msg)
    | Owner


type alias UserOptions msg =
    { isFollowing : Bool
    , isDisabled : Bool
    , onFollow : msg
    , onUnfollow : msg
    }


view : ViewOptions msg -> H.Html msg
view { username, imageUrl, bio, role } =
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
                        , HA.src <| Url.toString imageUrl
                        ]
                        []
                    , H.h4 [] [ H.text <| Username.toString username ]
                    , H.p [] [ H.text bio ]
                    , case role of
                        Guest ->
                            H.text ""

                        User { isFollowing, isDisabled, onFollow, onUnfollow } ->
                            FollowButton.view
                                { username = username
                                , isFollowing = isFollowing
                                , maybeTotalFollowers = Nothing
                                , isDisabled = isDisabled
                                , onFollow = onFollow
                                , onUnfollow = onUnfollow
                                }

                        Owner ->
                            H.a
                                [ HA.class "btn btn-sm btn-outline-secondary action-btn"
                                , HA.href <| Route.toString Route.Settings
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
