module Data.User exposing (User, decoder)

import Data.Email as Email exposing (Email)
import Data.Token as Token exposing (Token)
import Data.Username as Username exposing (Username)
import Json.Decode as JD
import Lib.Json.Decode as JD
import Url exposing (Url)


type alias User =
    { username : Username
    , email : Email
    , bio : String
    , imageUrl : Url
    , token : Token
    }


decoder : JD.Decoder User
decoder =
    JD.map5 User
        (JD.field "username" Username.decoder)
        (JD.field "email" Email.decoder)
        (JD.field "bio" JD.nullableString)
        (JD.field "image" JD.imageUrl)
        (JD.field "token" Token.decoder)
