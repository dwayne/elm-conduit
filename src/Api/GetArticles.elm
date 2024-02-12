module Api.GetArticles exposing
    ( Article
    , Articles
    , Author
    , Filter(..)
    , Options
    , getArticles
    )

import Api
import Data.Limit as Limit exposing (Limit)
import Data.Offset as Offset exposing (Offset)
import Data.Pager exposing (Page)
import Data.Slug as Slug exposing (Slug)
import Data.Tag as Tag exposing (Tag)
import Data.Timestamp as Timestamp exposing (Timestamp)
import Data.Total as Total exposing (Total)
import Data.Username as Username exposing (Username)
import Http
import Json.Decode as JD
import Json.Decode.Pipeline as JD
import Lib.Json.Decode as JD
import Url exposing (Url)
import Url.Builder as UB


type alias Options msg =
    { filter : Filter
    , page : Page
    , onResponse : Result (Api.Error ()) Articles -> msg
    }


type Filter
    = Global
    | ByTag Tag
    | ByAuthor Username
    | ByFavourite Username


getArticles : String -> Options msg -> Cmd msg
getArticles baseUrl { filter, page, onResponse } =
    Http.get
        { url =
            Api.buildUrl
                baseUrl
                [ "articles" ]
                [ UB.int "offset" <| Offset.toInt page.offset
                , UB.int "limit" <| Limit.toInt page.limit
                ]
                [ case filter of
                    Global ->
                        Nothing

                    ByTag tag ->
                        Just <| UB.string "tag" <| Tag.toString tag

                    ByAuthor username ->
                        Just <| UB.string "author" <| Username.toString username

                    ByFavourite username ->
                        Just <| UB.string "favorited" <| Username.toString username
                ]
        , expect = Api.expectJson onResponse decoder Api.emptyErrorsDecoder
        }


type alias Articles =
    { articles : List Article
    , totalArticles : Total
    }


type alias Article =
    { slug : Slug
    , title : String
    , description : String
    , body : String
    , tags : List Tag
    , createdAt : Timestamp
    , isFavourite : Bool
    , totalFavourites : Total
    , author : Author
    }


type alias Author =
    { username : Username
    , imageUrl : Url
    }


decoder : JD.Decoder Articles
decoder =
    JD.map2 Articles
        (JD.field "articles" <| JD.list articleDecoder)
        (JD.field "articlesCount" Total.decoder)


articleDecoder : JD.Decoder Article
articleDecoder =
    JD.succeed Article
        |> JD.required "slug" Slug.decoder
        |> JD.required "title" JD.string
        |> JD.required "description" JD.string
        |> JD.required "body" JD.string
        |> JD.required "tagList" (JD.list Tag.decoder)
        |> JD.required "createdAt" Timestamp.decoder
        |> JD.required "favorited" JD.bool
        |> JD.required "favoritesCount" Total.decoder
        |> JD.required "author" authorDecoder


authorDecoder : JD.Decoder Author
authorDecoder =
    JD.map2 Author
        (JD.field "username" Username.decoder)
        (JD.field "image" JD.url)
