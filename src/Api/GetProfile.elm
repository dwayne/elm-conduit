module Api.GetProfile exposing (Options, Profile, getProfile)

import Api
import Data.Token exposing (Token)
import Data.Username as Username exposing (Username)
import Json.Decode as JD
import Lib.Json.Decode as JD
import Url exposing (Url)


type alias Options msg =
    { maybeToken : Maybe Token
    , username : Username
    , onResponse : Result (Api.Error ()) Profile -> msg
    }


getProfile : Url -> Options msg -> Cmd msg
getProfile baseUrl { maybeToken, username, onResponse } =
    Api.get
        { maybeToken = maybeToken
        , url = Api.buildUrl baseUrl [ "profiles", Username.toString username ] [] []
        , onResponse = onResponse
        , decoder = decoder
        }


type alias Profile =
    { username : Username
    , imageUrl : Url
    , bio : String
    , isFollowing : Bool
    }


decoder : JD.Decoder Profile
decoder =
    JD.field "profile" <|
        JD.map4 Profile
            (JD.field "username" Username.decoder)
            (JD.field "image" JD.url)
            (JD.field "bio" JD.nullableString)
            (JD.field "following" JD.bool)
