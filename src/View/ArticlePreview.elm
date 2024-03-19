module View.ArticlePreview exposing (Role(..), ViewOptions, view, viewMessage)

import Data.Route as Route
import Data.Slug as Slug exposing (Slug)
import Data.Tag as Tag exposing (Tag)
import Data.Timestamp as Timestamp exposing (Timestamp)
import Data.Total as Total exposing (Total)
import Data.Username as Username exposing (Username)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Time
import Url exposing (Url)


type alias ViewOptions msg =
    { role : Role msg
    , username : Username
    , imageUrl : Url
    , zone : Time.Zone
    , createdAt : Timestamp
    , slug : Slug
    , title : String
    , description : String
    , tags : List Tag
    }


type Role msg
    = Guest
    | User
        { isLoading : Bool
        , totalFavourites : Total
        , isFavourite : Bool
        , onToggleFavourite : Bool -> msg
        }


view : ViewOptions msg -> H.Html msg
view { role, username, imageUrl, zone, createdAt, slug, title, description, tags } =
    let
        profileHref =
            Route.toString <| Route.Profile username
    in
    H.div
        [ HA.class "article-preview" ]
        [ H.div
            [ HA.class "article-meta" ]
            [ H.a
                [ HA.href profileHref ]
                [ H.img
                    [ HA.src <| Url.toString imageUrl ]
                    []
                ]
            , H.div
                [ HA.class "info" ]
                [ H.a
                    [ HA.class "author"
                    , HA.href profileHref
                    ]
                    [ H.text <| Username.toString username ]
                , H.span
                    [ HA.class "date" ]
                    [ H.text <| Timestamp.toDayString zone createdAt ]
                ]
            , case role of
                Guest ->
                    H.text ""

                User { isLoading, totalFavourites, isFavourite, onToggleFavourite } ->
                    H.button
                        [ HA.class "btn btn-sm pull-xs-right"
                        , HA.class <|
                            if isFavourite then
                                "btn-primary"

                            else
                                "btn-outline-primary"
                        , if isLoading then
                            HA.disabled True

                          else
                            HE.onClick (onToggleFavourite <| not isFavourite)
                        ]
                        [ H.i [ HA.class "ion-heart" ] []
                        , H.text " "
                        , H.text <| Total.toString totalFavourites
                        ]
            ]
        , H.a
            [ HA.class "preview-link"
            , HA.href <| Route.toString <| Route.Article slug
            ]
            [ H.h1 [] [ H.text title ]
            , H.p [] [ H.text description ]
            , H.span [] [ H.text "Read more..." ]
            , H.ul [ HA.class "tag-list" ] <|
                List.map
                    (\tag ->
                        H.li
                            [ HA.class "tag-default tag-pill tag-outline" ]
                            [ H.text <| Tag.toString tag ]
                    )
                    tags
            ]
        ]


viewMessage : String -> H.Html msg
viewMessage message =
    H.div
        [ HA.class "article-preview" ]
        [ H.text message ]
