module View.FollowButton exposing (FollowButton, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE


type alias FollowButton msg =
    { name : String
    , isFollowed : Bool
    , maybeTotalFollowers : Maybe Int
    , isDisabled : Bool
    , onFollow : msg
    , onUnfollow : msg
    }


view : FollowButton msg -> H.Html msg
view { name, isFollowed, maybeTotalFollowers, isDisabled, onFollow, onUnfollow } =
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
            , H.text <| "\u{00A0} " ++ action ++ " " ++ name
            ]

        optionalChildren =
            case maybeTotalFollowers of
                Nothing ->
                    []

                Just totalFollowers ->
                    [ H.text " "
                    , H.span
                        [ HA.class "counter" ]
                        [ H.text <| "(" ++ String.fromInt totalFollowers ++ ")" ]
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
