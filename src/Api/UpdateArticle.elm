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


type alias Options msg =
    { token : Token
    , slug : Slug
    , title : NonEmptyString
    , description : NonEmptyString
    , body : NonEmptyString
    , tags : List Tag
    , onResponse : Result (Api.Error (List String)) Article -> msg
    }


updateArticle : String -> Options msg -> Cmd msg
updateArticle baseUrl { token, slug, title, description, body, tags, onResponse } =
    Api.put
        { token = token
        , url = Api.buildUrl baseUrl [ "articles", Slug.toString slug ] [] []
        , body =
            Http.jsonBody <|
                encodeInput
                    { title = title
                    , description = description
                    , body = body
                    , tags = tags
                    }
        , onResponse = onResponse
        , decoder = decoder
        , errorsDecoder =
            Api.formErrorsDecoder
                [ "title"
                , "description"
                , "body"
                , "tagList"
                ]
        }


encodeInput :
    { title : NonEmptyString
    , description : NonEmptyString
    , body : NonEmptyString
    , tags : List Tag
    }
    -> JE.Value
encodeInput { title, description, body, tags } =
    JE.object
        [ ( "article"
          , JE.object
                [ ( "title", NonEmptyString.encode title )
                , ( "description", NonEmptyString.encode description )
                , ( "body", NonEmptyString.encode body )
                , ( "tagList", JE.list Tag.encode tags )
                ]
          )
        ]


decoder : JD.Decoder Article
decoder =
    JD.field "article" Article.decoder
