module Data.Config exposing (BadToken(..), Config, decoder)

import Data.Token as Token exposing (Token)
import Json.Decode as JD
import Url exposing (Url)


type alias Config =
    --
    -- TODO: Give apiUrl the Url type.
    --
    { apiUrl : String
    , resultMaybeToken : Result BadToken (Maybe Token)
    }


type BadToken
    = BadToken JD.Error


decoder : JD.Decoder Config
decoder =
    JD.map2 Config
        (JD.field "apiUrl" JD.string)
        (JD.field "maybeToken" tokenDecoder)


tokenDecoder : JD.Decoder (Result BadToken (Maybe Token))
tokenDecoder =
    JD.oneOf
        [ JD.map Ok (JD.nullable Token.decoder)

        --
        -- NOTE: It's possible that a token exists but it has been corrupted in
        -- some way. If that's the case we want to recognize the error but we
        -- don't want it to result in a decoder error. That way it's easier to
        -- detect when the situation occurs.
        --
        , JD.map (Err << BadToken << JD.Failure "Bad token") JD.value
        ]
