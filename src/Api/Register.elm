module Api.Register exposing (Options, RegistrationDetails, register)

import Api
import Data.Email as Email exposing (Email)
import Data.Password as Password exposing (Password)
import Data.Token as Token exposing (Token)
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
    , onResponse : Result (Api.Error (List String)) RegistrationDetails -> msg
    }


register : String -> Options msg -> Cmd msg
register baseUrl { username, email, password, onResponse } =
    Http.post
        { url = Api.buildUrl baseUrl [ "users" ] [] []
        , body =
            Http.jsonBody <|
                encodeUser username email password
        , expect =
            Api.expectJson onResponse decoder <|
                Api.formErrorsDecoder [ "username", "email", "password " ]
        }


encodeUser : Username -> Email -> Password -> JE.Value
encodeUser username email password =
    JE.object
        [ ( "user"
          , JE.object
                [ ( "username", Username.encode username )
                , ( "email", Email.encode email )
                , ( "password", Password.encode password )
                ]
          )
        ]


type alias RegistrationDetails =
    { id : Int
    , username : Username
    , email : Email
    , bio : String
    , imageUrl : Url
    , token : Token
    }


decoder : JD.Decoder RegistrationDetails
decoder =
    JD.field "user" <|
        JD.map6 RegistrationDetails
            (JD.field "id" JD.int)
            (JD.field "username" Username.decoder)
            (JD.field "email" Email.decoder)
            (JD.field "bio" JD.nullableString)
            (JD.field "image" JD.url)
            (JD.field "token" Token.decoder)
