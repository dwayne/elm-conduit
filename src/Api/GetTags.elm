module Api.GetTags exposing (Options, getTags)

import Api
import Data.Tag as Tag exposing (Tag)
import Http
import Json.Decode as JD


type alias Options msg =
    { onResponse : Result Http.Error Response -> msg
    }


getTags : String -> Options msg -> Cmd msg
getTags baseUrl { onResponse } =
    Http.get
        { url =
            Api.buildUrl
                baseUrl
                [ "tags" ]
                []
        , expect = Http.expectJson onResponse decoder
        }


type alias Response =
    List Tag


decoder : JD.Decoder Response
decoder =
    JD.field "tags" (JD.list Tag.decoder)
