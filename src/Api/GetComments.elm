module Api.GetComments exposing (Options, getComments)

import Api
import Data.Comments as Comments exposing (Comments)
import Data.Slug as Slug exposing (Slug)
import Data.Token exposing (Token)
import Json.Decode as JD
import Url exposing (Url)


type alias Options msg =
    { maybeToken : Maybe Token
    , slug : Slug
    , onResponse : Result (Api.Error ()) Comments -> msg
    }


getComments : Url -> Options msg -> Cmd msg
getComments baseUrl { maybeToken, slug, onResponse } =
    Api.get
        { maybeToken = maybeToken
        , url = Api.buildUrl baseUrl [ "articles", Slug.toString slug, "comments" ] [] []
        , onResponse = onResponse
        , decoder = decoder
        }


decoder : JD.Decoder Comments
decoder =
    JD.field "comments" Comments.decoder
