module Api.GetArticles exposing
    ( Articles
    , Options
    , Request
    , byAuthor
    , byFavourites
    , byTag
    , fromUsersYouFollow
    , getArticles
    , global
    )

import Api
import Data.Article as Article exposing (Article)
import Data.Limit as Limit
import Data.Offset as Offset
import Data.Pager exposing (Page)
import Data.Tag as Tag exposing (Tag)
import Data.Token exposing (Token)
import Data.Total as Total exposing (Total)
import Data.Username as Username exposing (Username)
import Json.Decode as JD
import Url exposing (Url)
import Url.Builder as UB


type alias Options msg =
    { request : Request
    , page : Page
    , onResponse : Result (Api.Error ()) Articles -> msg
    }


type Request
    = FromUsersYouFollow Token
    | Global (Maybe Token) Filter


type Filter
    = None
    | ByTag Tag
    | ByAuthor Username
    | ByFavourites Username


fromUsersYouFollow : Token -> Request
fromUsersYouFollow =
    FromUsersYouFollow


global : Maybe Token -> Request
global maybeToken =
    Global maybeToken None


byTag : Maybe Token -> Tag -> Request
byTag maybeToken =
    Global maybeToken << ByTag


byAuthor : Maybe Token -> Username -> Request
byAuthor maybeToken =
    Global maybeToken << ByAuthor


byFavourites : Maybe Token -> Username -> Request
byFavourites maybeToken =
    Global maybeToken << ByFavourites


getArticles : Url -> Options msg -> Cmd msg
getArticles baseUrl { request, page, onResponse } =
    case request of
        FromUsersYouFollow token ->
            getArticlesFromUsersYouFollow baseUrl token page onResponse

        Global maybeToken filter ->
            getArticlesGlobally baseUrl maybeToken filter page onResponse


getArticlesFromUsersYouFollow : Url -> Token -> Page -> (Result (Api.Error ()) Articles -> msg) -> Cmd msg
getArticlesFromUsersYouFollow baseUrl token page onResponse =
    Api.get
        { maybeToken = Just token
        , url =
            Api.buildUrl
                baseUrl
                [ "articles", "feed" ]
                [ UB.int "offset" <| Offset.toInt page.offset
                , UB.int "limit" <| Limit.toInt page.limit
                ]
                []
        , onResponse = onResponse
        , decoder = decoder
        }


getArticlesGlobally : Url -> Maybe Token -> Filter -> Page -> (Result (Api.Error ()) Articles -> msg) -> Cmd msg
getArticlesGlobally baseUrl maybeToken filter page onResponse =
    Api.get
        { maybeToken = maybeToken
        , url =
            Api.buildUrl
                baseUrl
                [ "articles" ]
                [ UB.int "offset" <| Offset.toInt page.offset
                , UB.int "limit" <| Limit.toInt page.limit
                ]
                [ case filter of
                    None ->
                        Nothing

                    ByTag tag ->
                        Just <| UB.string "tag" <| Tag.toString tag

                    ByAuthor username ->
                        Just <| UB.string "author" <| Username.toString username

                    ByFavourites username ->
                        Just <| UB.string "favorited" <| Username.toString username
                ]
        , onResponse = onResponse
        , decoder = decoder
        }


type alias Articles =
    { articles : List Article
    , totalArticles : Total
    }


decoder : JD.Decoder Articles
decoder =
    JD.map2 Articles
        (JD.field "articles" <| JD.list Article.decoder)
        (JD.field "articlesCount" Total.decoder)
