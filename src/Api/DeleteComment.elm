module Api.DeleteComment exposing (Options, deleteComment)

import Api
import Data.Slug as Slug exposing (Slug)
import Data.Token as Token exposing (Token)


type alias Options msg =
    { token : Token
    , slug : Slug
    , id : Int
    , onResponse : Result (Api.Error ()) Int -> msg
    }


deleteComment : String -> Options msg -> Cmd msg
deleteComment baseUrl { token, slug, id, onResponse } =
    Api.delete
        { token = token
        , url = Api.buildUrl baseUrl [ "articles", Slug.toString slug, "comments", String.fromInt id ] [] []
        , default = id
        , onResponse = onResponse
        }
