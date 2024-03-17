module Api.CreateArticle exposing (Options, createArticle)

import Api
import Data.Article as Article exposing (Article)
import Data.Tag as Tag exposing (Tag)
import Data.Token as Token exposing (Token)
import Http
import Json.Decode as JD
import Json.Encode as JE
import Lib.NonEmptyString as NonEmptyString exposing (NonEmptyString)
import Url exposing (Url)


type alias Options msg =
    { token : Token
    , articleFields : Article.Fields
    , onResponse : Result (Api.Error (List String)) Article -> msg
    }


createArticle : Url -> Options msg -> Cmd msg
createArticle baseUrl { token, articleFields, onResponse } =
    Api.post
        { maybeToken = Just token
        , url = Api.buildUrl baseUrl [ "articles" ] [] []
        , body = Http.jsonBody <| encodeInput articleFields
        , onResponse = onResponse
        , decoder = decoder
        , errorsDecoder = Api.formErrorsDecoder Article.fieldNames
        }


encodeInput : Article.Fields -> JE.Value
encodeInput fields =
    JE.object [ ( "article", Article.encode fields ) ]


decoder : JD.Decoder Article
decoder =
    JD.field "article" Article.decoder
