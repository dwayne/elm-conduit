module View.ArticlePreview exposing (ViewOptions, view)

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
    { username : Username
    , imageUrl : Url
    , zone : Time.Zone
    , timestamp : Timestamp
    , totalFavourites : Total
    , isFavourite : Bool
    , slug : Slug
    , title : String
    , description : String
    , tags : List Tag
    , onToggleFavourite : Bool -> msg
    }


view : ViewOptions msg -> H.Html msg
view { username, imageUrl, zone, timestamp, totalFavourites, isFavourite, slug, title, description, tags, onToggleFavourite } =
    let
        profileHref =
            Route.toString <| Route.Profile False username
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
                    [ H.text <| Timestamp.toString zone timestamp ]
                ]
            , H.button
                [ HA.class "btn btn-sm pull-xs-right"
                , HA.class <|
                    if isFavourite then
                        "btn-primary"

                    else
                        "btn-outline-primary"
                , HE.onClick (onToggleFavourite <| not isFavourite)
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
