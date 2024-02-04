module View.ArticleHeader exposing
    ( ArticleHeader
    , GuestOptions
    , OwnerOptions
    , Role(..)
    , view
    )

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import View.FavouriteButton as FavouriteButton
import View.FollowButton as FollowButton


type alias ArticleHeader msg =
    { title : String
    , name : String
    , imageUrl : String
    , date : String
    , role : Role msg
    }


type Role msg
    = Guest (GuestOptions msg)
    | Owner (OwnerOptions msg)


type alias GuestOptions msg =
    { isDisabled : Bool
    , isFollowed : Bool
    , totalFollowers : Int
    , onFollow : msg
    , onUnfollow : msg
    , isFavourite : Bool
    , totalFavourites : Int
    , onFavourite : msg
    , onUnfavourite : msg
    }


type alias OwnerOptions msg =
    { isDisabled : Bool
    , onDelete : msg
    }


view : ArticleHeader msg -> H.Html msg
view { title, name, imageUrl, date, role } =
    let
        buttons =
            case role of
                Guest { isDisabled, isFollowed, totalFollowers, onFollow, onUnfollow, isFavourite, totalFavourites, onFavourite, onUnfavourite } ->
                    [ FollowButton.view
                        { name = name
                        , isFollowed = isFollowed
                        , maybeTotalFollowers = Just totalFollowers
                        , isDisabled = isDisabled
                        , onFollow = onFollow
                        , onUnfollow = onUnfollow
                        }
                    , H.text "\u{00A0}\u{00A0}"
                    , FavouriteButton.view
                        { isFavourite = isFavourite
                        , totalFavourites = totalFavourites
                        , isDisabled = isDisabled
                        , onFavourite = onFavourite
                        , onUnfavourite = onUnfavourite
                        }
                    ]

                Owner { isDisabled, onDelete } ->
                    [ H.a
                        [ HA.class "btn btn-sm btn-outline-secondary"
                        , HA.href "./editor.html"
                        ]
                        [ H.i [ HA.class "ion-edit" ] []
                        , H.text " Edit Article"
                        ]
                    , H.text "\u{00A0}\u{00A0}"
                    , H.button
                        [ HA.class "btn btn-sm btn-outline-danger"
                        , if isDisabled then
                            HA.disabled True

                          else
                            HE.onClick onDelete
                        ]
                        [ H.i [ HA.class "ion-trash-a" ] []
                        , H.text " Delete Article"
                        ]
                    ]
    in
    H.div
        [ HA.class "banner" ]
        [ H.div
            [ HA.class "container" ]
            [ H.h1 [] [ H.text title ]
            , H.div [ HA.class "article-meta" ] <|
                List.append
                    [ H.a
                        [ HA.href "./profile.html" ]
                        [ H.img [ HA.src imageUrl ] [] ]
                    , H.div
                        [ HA.class "info" ]
                        [ H.a
                            [ HA.class "author"
                            , HA.href "./profile.html"
                            ]
                            [ H.text name ]
                        , H.span
                            [ HA.class "date" ]
                            [ H.text date ]
                        ]
                    ]
                    buttons
            ]
        ]
