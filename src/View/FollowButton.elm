module View.FollowButton exposing
    ( FollowButton(..)
    , FollowOptions
    , UnfollowOptions
    , view
    )

import Html as H
import Html.Attributes as HA
import Html.Events as HE


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


view : String -> FollowButton msg -> H.Html msg
view username followButton =
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
