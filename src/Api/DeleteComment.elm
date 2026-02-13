module Api.DeleteComment exposing (Options, deleteComment)

import Api
import Data.Slug as Slug exposing (Slug)
import Data.Token exposing (Token)
import Url exposing (Url)


type alias Options msg =
    { token : Token
    , slug : Slug
    , id : String
    , onResponse : Result (Api.Error ()) String -> msg
    }


deleteComment : Url -> Options msg -> Cmd msg
deleteComment baseUrl { token, slug, id, onResponse } =
    Api.delete
        { token = token
        , url = Api.buildUrl baseUrl [ "articles", Slug.toString slug, "comments", id ] [] []
        , default = id
        , onResponse = onResponse
        }
