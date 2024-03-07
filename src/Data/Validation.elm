module Data.Validation exposing (bio, email, imageUrl, optionalPassword, password, username)

import Data.Email as Email exposing (Email)
import Data.Password as Password exposing (Password)
import Data.Username as Username exposing (Username)
import Lib.String as String
import Lib.Validation as V
import Url exposing (Url)


bio : String -> V.Validation String
bio =
    V.succeed


email : String -> V.Validation Email
email s =
    case Email.fromString s of
        Just validEmail ->
            V.succeed validEmail

        Nothing ->
            V.fail "email can't be blank"


imageUrl : String -> V.Validation Url
imageUrl s =
    let
        t =
            String.trim s
    in
    if String.isEmpty t then
        V.fail "image can't be blank"

    else
        case Url.fromString t of
            Just validUrl ->
                V.succeed validUrl

            Nothing ->
                V.fail "image is invalid"


password : String -> V.Validation Password
password s =
    case Password.fromString s of
        Ok validPassword ->
            V.succeed validPassword

        Err Password.Blank ->
            V.fail "password can't be blank"

        Err (Password.TooShort expectedLength) ->
            V.fail <| passwordTooShortMessage expectedLength


optionalPassword : String -> V.Validation (Maybe Password)
optionalPassword s =
    case Password.fromString s of
        Ok validPassword ->
            V.succeed <| Just validPassword

        Err Password.Blank ->
            V.succeed Nothing

        Err (Password.TooShort expectedLength) ->
            V.fail <| passwordTooShortMessage expectedLength


passwordTooShortMessage : Int -> String
passwordTooShortMessage expectedLength =
    String.concat
        [ "password must be at least "
        , String.fromInt expectedLength
        , " "
        , String.pluralize
            expectedLength
            { singular = "character"
            , plural = "characters"
            }
        , " long"
        ]


username : String -> V.Validation Username
username s =
    case Username.fromString s of
        Just validUsername ->
            V.succeed validUsername

        Nothing ->
            V.fail "username can't be blank"
