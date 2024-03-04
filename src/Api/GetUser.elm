module Api.GetUser exposing (Options, getUser)

import Api
import Data.Token as Token exposing (Token)
import Data.User as User exposing (User)
import Http
import Json.Decode as JD


type alias Options msg =
    { token : Token
    , onResponse : Result (Api.Error ()) User -> msg
    }


getUser : String -> Options msg -> Cmd msg
getUser baseUrl { token, onResponse } =
    Http.request
        { method = "GET"
        , headers = [ Token.toAuthorizationHeader token ]
        , url =
            Api.buildUrl
                baseUrl
                [ "user" ]
                []
                []
        , body = Http.emptyBody
        , expect = Api.expectJson onResponse decoder Api.emptyErrorsDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


decoder : JD.Decoder User
decoder =
    JD.field "user" User.decoder
