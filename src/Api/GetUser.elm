module Api.GetUser exposing (Options, getUser)

import Api
import Data.Token as Token exposing (Token)
import Data.User as User exposing (User)
import Json.Decode as JD
import Url exposing (Url)


type alias Options msg =
    { token : Token
    , onResponse : Result (Api.Error ()) User -> msg
    }


getUser : Url -> Options msg -> Cmd msg
getUser baseUrl { token, onResponse } =
    Api.get
        { maybeToken = Just token
        , url = Api.buildUrl baseUrl [ "user" ] [] []
        , onResponse = onResponse
        , decoder = decoder
        }


decoder : JD.Decoder User
decoder =
    JD.field "user" User.decoder
