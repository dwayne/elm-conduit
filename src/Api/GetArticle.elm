module Api.GetArticle exposing (Options, getArticle)

import Api
import Data.Article as Article exposing (Article)
import Data.Slug as Slug exposing (Slug)
import Data.Token exposing (Token)
import Json.Decode as JD
import Url exposing (Url)


type alias Options msg =
    { maybeToken : Maybe Token
    , slug : Slug
    , onResponse : Result (Api.Error ()) Article -> msg
    }


getArticle : Url -> Options msg -> Cmd msg
getArticle baseUrl { maybeToken, slug, onResponse } =
    Api.get
        { maybeToken = maybeToken
        , url = Api.buildUrl baseUrl [ "articles", Slug.toString slug ] [] []
        , onResponse = onResponse
        , decoder = decoder
        }


decoder : JD.Decoder Article
decoder =
    JD.field "article" Article.decoder
