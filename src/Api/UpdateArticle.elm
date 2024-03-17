module Api.UpdateArticle exposing (Options, updateArticle)

import Api
import Data.Article as Article exposing (Article)
import Data.Slug as Slug exposing (Slug)
import Data.Tag as Tag exposing (Tag)
import Data.Token as Token exposing (Token)
import Http
import Json.Decode as JD
import Json.Encode as JE
import Lib.NonEmptyString as NonEmptyString exposing (NonEmptyString)
import Url exposing (Url)


type alias Options msg =
    { token : Token
    , slug : Slug
    , articleFields : Article.Fields
    , onResponse : Result (Api.Error (List String)) Article -> msg
    }


updateArticle : Url -> Options msg -> Cmd msg
updateArticle baseUrl { token, slug, articleFields, onResponse } =
    Api.put
        { token = token
        , url = Api.buildUrl baseUrl [ "articles", Slug.toString slug ] [] []
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
