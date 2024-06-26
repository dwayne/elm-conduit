module Api.Login exposing (Options, login)

import Api
import Data.Email as Email exposing (Email)
import Data.Password as Password exposing (Password)
import Data.User as User exposing (User)
import Http
import Json.Decode as JD
import Json.Encode as JE
import Url exposing (Url)


type alias Options msg =
    { email : Email
    , password : Password
    , onResponse : Result (Api.Error (List String)) User -> msg
    }


login : Url -> Options msg -> Cmd msg
login baseUrl { email, password, onResponse } =
    Api.post
        { maybeToken = Nothing
        , url = Api.buildUrl baseUrl [ "users", "login" ] [] []
        , body = Http.jsonBody <| encodeInput email password
        , onResponse = onResponse
        , decoder = decoder
        , errorsDecoder =
            Api.formErrorsDecoder
                [ "email"
                , "password"
                , "email or password"
                ]
        }


encodeInput : Email -> Password -> JE.Value
encodeInput email password =
    JE.object
        [ ( "user"
          , JE.object
                [ ( "email", Email.encode email )
                , ( "password", Password.encode password )
                ]
          )
        ]


decoder : JD.Decoder User
decoder =
    JD.field "user" User.decoder
