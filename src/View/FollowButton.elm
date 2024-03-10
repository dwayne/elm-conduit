module View.FollowButton exposing (ViewOptions, view)

import Data.Total as Total exposing (Total)
import Data.Username as Username exposing (Username)
import Html as H
import Html.Attributes as HA
import Html.Events as HE


type alias ViewOptions msg =
    { username : Username
    , isFollowed : Bool
    , maybeTotalFollowers : Maybe Total
    , isDisabled : Bool
    , onFollow : msg
    , onUnfollow : msg
    }


view : ViewOptions msg -> H.Html msg
view { username, isFollowed, maybeTotalFollowers, isDisabled, onFollow, onUnfollow } =
    let
        { action, buttonClass, iconClass, onClick } =
            if isFollowed then
                { action = "Unfollow"
                , buttonClass = "btn-secondary"
                , iconClass = "ion-minus-round"
                , onClick = onUnfollow
                }

            else
                { action = "Follow"
                , buttonClass = "btn-outline-secondary"
                , iconClass = "ion-plus-round"
                , onClick = onFollow
                }

        requiredChildren =
            [ H.i
                [ HA.class iconClass ]
                []
            , H.text <| "\u{00A0} " ++ action ++ " " ++ Username.toString username
            ]

        optionalChildren =
            case maybeTotalFollowers of
                Nothing ->
                    []

                Just totalFollowers ->
                    [ H.text " "
                    , H.span
                        [ HA.class "counter" ]
                        [ H.text <| "(" ++ Total.toString totalFollowers ++ ")" ]
                    ]
    in
    H.button
        [ HA.class "btn btn-sm action-btn"
        , HA.class buttonClass
        , if isDisabled then
            HA.disabled True

          else
            HE.onClick onClick
        ]
        (requiredChildren ++ optionalChildren)
