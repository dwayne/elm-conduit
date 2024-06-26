module View.ArticleMeta exposing
    ( AuthorOptions
    , Role(..)
    , UserOptions
    , ViewOptions
    , view
    )

import Data.Route as Route
import Data.Slug exposing (Slug)
import Data.Timestamp as Timestamp exposing (Timestamp)
import Data.Total exposing (Total)
import Data.Username as Username exposing (Username)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Time
import Url exposing (Url)
import View.FavouriteButton as FavouriteButton
import View.FollowButton as FollowButton


type alias ViewOptions msg =
    { username : Username
    , imageUrl : Url
    , zone : Time.Zone
    , createdAt : Timestamp
    , role : Role msg
    }


type Role msg
    = Guest
    | User (UserOptions msg)
    | Author (AuthorOptions msg)


type alias UserOptions msg =
    { isDisabled : Bool
    , isFollowing : Bool
    , onFollow : msg
    , onUnfollow : msg
    , isFavourite : Bool
    , totalFavourites : Total
    , onFavourite : msg
    , onUnfavourite : msg
    }


type alias AuthorOptions msg =
    { isDisabled : Bool
    , slug : Slug
    , onDelete : Slug -> msg
    }


view : ViewOptions msg -> H.Html msg
view { username, imageUrl, zone, createdAt, role } =
    let
        profileUrl =
            Route.toString <| Route.Profile username

        buttons =
            case role of
                Guest ->
                    []

                User { isDisabled, isFollowing, onFollow, onUnfollow, isFavourite, totalFavourites, onFavourite, onUnfavourite } ->
                    [ FollowButton.view
                        { username = username
                        , isFollowing = isFollowing
                        , maybeTotalFollowers = Nothing
                        , isDisabled = isDisabled
                        , onFollow = onFollow
                        , onUnfollow = onUnfollow
                        }
                    , viewSpace
                    , FavouriteButton.view
                        { isFavourite = isFavourite
                        , totalFavourites = totalFavourites
                        , isDisabled = isDisabled
                        , onFavourite = onFavourite
                        , onUnfavourite = onUnfavourite
                        }
                    ]

                Author { isDisabled, slug, onDelete } ->
                    [ H.a
                        [ HA.class "btn btn-sm btn-outline-secondary"
                        , HA.href <| Route.toString <| Route.EditArticle slug
                        ]
                        [ H.i [ HA.class "ion-edit" ] []
                        , H.text "\u{00A0} Edit Article"
                        ]
                    , viewSpace
                    , H.button
                        [ HA.class "btn btn-sm btn-outline-danger"
                        , if isDisabled then
                            HA.disabled True

                          else
                            HE.onClick <| onDelete slug
                        ]
                        [ H.i [ HA.class "ion-trash-a" ] []
                        , H.text "\u{00A0} Delete Article"
                        ]
                    ]
    in
    H.div [ HA.class "article-meta" ] <|
        List.append
            [ H.a
                [ HA.href profileUrl ]
                [ H.img [ HA.src <| Url.toString imageUrl ] [] ]
            , H.div
                [ HA.class "info" ]
                [ H.a
                    [ HA.class "author"
                    , HA.href profileUrl
                    ]
                    [ H.text <| Username.toString username ]
                , H.span
                    [ HA.class "date" ]
                    [ H.text <| Timestamp.toDayString zone createdAt ]
                ]
            ]
            buttons


viewSpace : H.Html msg
viewSpace =
    H.text "\u{00A0}\u{00A0}"
