module Api.UpdateUser exposing (Options, updateUser)

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
import Lib.Json.Encode as JE
import Url exposing (Url)


type alias Options msg =
    { token : Token
    , imageUrl : Url
    , username : Username
    , bio : String
    , email : Email
    , maybePassword : Maybe Password
    , onResponse : Result (Api.Error (List String)) User -> msg
    }


updateUser : Url -> Options msg -> Cmd msg
updateUser baseUrl { token, imageUrl, username, bio, email, maybePassword, onResponse } =
    Api.put
        { token = token
        , url = Api.buildUrl baseUrl [ "user" ] [] []
        , body =
            Http.jsonBody <|
                encodeInput imageUrl username bio email maybePassword
        , onResponse = onResponse
        , decoder = decoder
        , errorsDecoder =
            Api.formErrorsDecoder
                [ "image"
                , "username"
                , "bio"
                , "email"
                , "password"
                ]
        }


encodeInput : Url -> Username -> String -> Email -> Maybe Password -> JE.Value
encodeInput imageUrl username bio email maybePassword =
    JE.object
        [ ( "user"
          , JE.object
                ([ ( "image", JE.url imageUrl )
                 , ( "username", Username.encode username )
                 , ( "bio", JE.string bio )
                 , ( "email", Email.encode email )
                 ]
                    ++ (case maybePassword of
                            Just password ->
                                [ ( "password", Password.encode password ) ]

                            Nothing ->
                                []
                       )
                )
          )
        ]


decoder : JD.Decoder User
decoder =
    JD.field "user" User.decoder
