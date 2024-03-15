module Api.CreateComment exposing (Options, createComment)

import Api
import Data.Comment as Comment exposing (Comment)
import Data.Slug as Slug exposing (Slug)
import Data.Token exposing (Token)
import Http
import Json.Decode as JD
import Json.Encode as JE
import Lib.NonEmptyString as NonEmptyString exposing (NonEmptyString)


type alias Options msg =
    { token : Token
    , slug : Slug
    , comment : NonEmptyString
    , onResponse : Result (Api.Error ()) Comment -> msg
    }


createComment : String -> Options msg -> Cmd msg
createComment baseUrl { token, slug, comment, onResponse } =
    Api.post
        { maybeToken = Just token
        , url =
            Api.buildUrl
                baseUrl
                [ "articles", Slug.toString slug, "comments" ]
                []
                []
        , body = Http.jsonBody <| encodeInput comment
        , onResponse = onResponse
        , decoder = decoder
        , errorsDecoder = Api.emptyErrorsDecoder
        }


encodeInput : NonEmptyString -> JE.Value
encodeInput comment =
    JE.object
        [ ( "comment"
          , JE.object [ ( "body", NonEmptyString.encode comment ) ]
          )
        ]


decoder : JD.Decoder Comment
decoder =
    JD.field "comment" Comment.decoder
