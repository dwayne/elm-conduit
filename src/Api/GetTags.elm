module Api.GetTags exposing (Options, Tags, getTags)

import Api
import Data.Tag as Tag exposing (Tag)
import Http
import Json.Decode as JD


type alias Options msg =
    { onResponse : Result (Api.Error ()) Tags -> msg
    }


getTags : String -> Options msg -> Cmd msg
getTags baseUrl { onResponse } =
    Http.get
        { url = Api.buildUrl baseUrl [ "tags" ] [] []
        , expect = Api.expectJson onResponse decoder Api.emptyErrorsDecoder
        }


type alias Tags =
    List Tag


decoder : JD.Decoder Tags
decoder =
    JD.field "tags" (JD.list Tag.decoder)
