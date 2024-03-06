module Api exposing
    ( Error(..)
    , buildUrl
    , emptyErrorsDecoder
    , expectJson
    , formErrorsDecoder
    )

import Dict exposing (Dict)
import Http
import Json.Decode as JD
import Lib.Function exposing (flip)
import Url.Builder as UB


buildUrl : String -> List String -> List UB.QueryParameter -> List (Maybe UB.QueryParameter) -> String
buildUrl baseUrl pathSegments requiredParameters optionalParameters =
    UB.crossOrigin
        baseUrl
        pathSegments
        (requiredParameters ++ List.filterMap identity optionalParameters)


type Error e
    = BadUrl String
    | Timeout
    | NetworkError
    | BadStatus Int
    | BadBody Int String
    | Unauthorized
    | NotFound
    | UserError e


expectJson : (Result (Error e) a -> msg) -> JD.Decoder a -> JD.Decoder e -> Http.Expect msg
expectJson toMsg decoder errorsDecoder =
    Http.expectStringResponse toMsg <|
        \response ->
            case response of
                Http.BadUrl_ url ->
                    Err (BadUrl url)

                Http.Timeout_ ->
                    Err Timeout

                Http.NetworkError_ ->
                    Err NetworkError

                Http.BadStatus_ { statusCode } body ->
                    case statusCode of
                        401 ->
                            Err Unauthorized

                        404 ->
                            Err NotFound

                        _ ->
                            --
                            -- N.B. The 403 status code is undocumented but I encountered it
                            -- on the login form. If you provide an invalid email and password
                            -- then the server responds with the 403 status code and the error
                            -- message is "email or password is invalid".
                            --
                            if List.member statusCode [ 403, 422 ] then
                                case JD.decodeString (JD.field "errors" errorsDecoder) body of
                                    Ok errors ->
                                        Err (UserError errors)

                                    Err err ->
                                        Err (BadBody statusCode <| JD.errorToString err)

                            else
                                Err (BadStatus statusCode)

                Http.GoodStatus_ { statusCode } body ->
                    case JD.decodeString decoder body of
                        Ok value ->
                            Ok value

                        Err err ->
                            Err (BadBody statusCode <| JD.errorToString err)


emptyErrorsDecoder : JD.Decoder ()
emptyErrorsDecoder =
    JD.succeed ()


formErrorsDecoder : List String -> JD.Decoder (List String)
formErrorsDecoder keys =
    JD.dict (JD.list JD.string)
        |> JD.map
            (\dict ->
                List.concatMap (flip getErrorMessagesForKey dict) keys
            )


getErrorMessagesForKey : String -> Dict String (List String) -> List String
getErrorMessagesForKey key =
    Dict.get key
        >> Maybe.withDefault []
        >> List.map (\value -> key ++ " " ++ value)
