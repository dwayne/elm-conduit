module Api.ToggleFollow exposing (toggleFollow)

import Api
import Data.Token as Token exposing (Token)
import Data.Username as Username exposing (Username)
import Http
import Json.Decode as JD
import Lib.Either as Either
import Url exposing (Url)


type alias Options msg =
    { token : Token
    , username : Username
    , isFollowing : Bool
    , onResponse : Result (Api.Error ()) Bool -> msg
    }


toggleFollow : Url -> Options msg -> Cmd msg
toggleFollow baseUrl { token, username, isFollowing, onResponse } =
    Api.request
        { method =
            if isFollowing then
                Api.POST

            else
                Api.DELETE
        , maybeToken = Just token
        , url =
            Api.buildUrl
                baseUrl
                [ "profiles", Username.toString username, "follow" ]
                []
                []
        , body = Http.emptyBody
        , onResponse = onResponse
        , eitherDefaultOrDecoder = Either.Right decoder
        , errorsDecoder = Api.emptyErrorsDecoder
        }


decoder : JD.Decoder Bool
decoder =
    JD.at [ "profile", "following" ] JD.bool
