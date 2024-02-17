module Api.Register exposing (Options, register)

import Api
import Data.Email as Email exposing (Email)
import Data.Password as Password exposing (Password)
import Data.Token as Token exposing (Token)
import Data.User as User exposing (User)
import Data.Username as Username exposing (Username)
import Http
import Json.Decode as JD
import Json.Encode as JE
import Lib.Json.Decode as JD
import Url exposing (Url)


type alias Options msg =
    { username : Username
    , email : Email
    , password : Password
    , onResponse : Result (Api.Error (List String)) User -> msg
    }


register : String -> Options msg -> Cmd msg
register baseUrl { username, email, password, onResponse } =
    Http.post
        { url = Api.buildUrl baseUrl [ "users" ] [] []
        , body =
            Http.jsonBody <|
                encodeInput username email password
        , expect =
            Api.expectJson onResponse decoder <|
                Api.formErrorsDecoder [ "username", "email", "password " ]
        }


encodeInput : Username -> Email -> Password -> JE.Value
encodeInput username email password =
    JE.object
        [ ( "user"
          , JE.object
                [ ( "username", Username.encode username )
                , ( "email", Email.encode email )
                , ( "password", Password.encode password )
                ]
          )
        ]


decoder : JD.Decoder User
decoder =
    JD.field "user" User.decoder
