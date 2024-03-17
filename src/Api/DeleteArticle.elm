module Api.DeleteArticle exposing (Options, deleteArticle)

import Api
import Data.Slug as Slug exposing (Slug)
import Data.Token as Token exposing (Token)
import Url exposing (Url)


type alias Options msg =
    { token : Token
    , slug : Slug
    , onResponse : Result (Api.Error ()) () -> msg
    }


deleteArticle : Url -> Options msg -> Cmd msg
deleteArticle baseUrl { token, slug, onResponse } =
    Api.delete
        { token = token
        , url = Api.buildUrl baseUrl [ "articles", Slug.toString slug ] [] []
        , default = ()
        , onResponse = onResponse
        }
