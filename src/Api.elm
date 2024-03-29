module Api exposing
    ( Error(..)
    , FormModel
    , Method(..)
    , buildUrl
    , delete
    , emptyErrorsDecoder
    , errorToString
    , formErrorsDecoder
    , get
    , handleFormResponse
    , post
    , put
    , request
    )

import Data.Token as Token exposing (Token)
import Dict exposing (Dict)
import Http
import Json.Decode as JD
import Lib.Either as Either exposing (Either)
import Lib.Function exposing (flip)
import Url exposing (Url)
import Url.Builder as UB


get :
    { maybeToken : Maybe Token
    , url : String
    , onResponse : Result (Error ()) a -> msg
    , decoder : JD.Decoder a
    }
    -> Cmd msg
get { maybeToken, url, onResponse, decoder } =
    request
        { method = GET
        , maybeToken = maybeToken
        , url = url
        , body = Http.emptyBody
        , onResponse = onResponse
        , eitherDefaultOrDecoder = Either.Right decoder
        , errorsDecoder = emptyErrorsDecoder
        }


post :
    { maybeToken : Maybe Token
    , url : String
    , body : Http.Body
    , onResponse : Result (Error e) a -> msg
    , decoder : JD.Decoder a
    , errorsDecoder : JD.Decoder e
    }
    -> Cmd msg
post { maybeToken, url, body, onResponse, decoder, errorsDecoder } =
    request
        { method = POST
        , maybeToken = maybeToken
        , url = url
        , body = body
        , onResponse = onResponse
        , eitherDefaultOrDecoder = Either.Right decoder
        , errorsDecoder = errorsDecoder
        }


put :
    { token : Token
    , url : String
    , body : Http.Body
    , onResponse : Result (Error e) a -> msg
    , decoder : JD.Decoder a
    , errorsDecoder : JD.Decoder e
    }
    -> Cmd msg
put { token, url, body, onResponse, decoder, errorsDecoder } =
    request
        { method = PUT
        , maybeToken = Just token
        , url = url
        , body = body
        , onResponse = onResponse
        , eitherDefaultOrDecoder = Either.Right decoder
        , errorsDecoder = errorsDecoder
        }


delete :
    { token : Token
    , url : String
    , default : a
    , onResponse : Result (Error ()) a -> msg
    }
    -> Cmd msg
delete { token, url, default, onResponse } =
    request
        { method = DELETE
        , maybeToken = Just token
        , url = url
        , body = Http.emptyBody
        , onResponse = onResponse
        , eitherDefaultOrDecoder = Either.Left default
        , errorsDecoder = emptyErrorsDecoder
        }


type Method
    = GET
    | POST
    | PUT
    | DELETE


request :
    { method : Method
    , maybeToken : Maybe Token
    , url : String
    , body : Http.Body
    , onResponse : Result (Error e) a -> msg
    , eitherDefaultOrDecoder : Either a (JD.Decoder a)
    , errorsDecoder : JD.Decoder e
    }
    -> Cmd msg
request { method, maybeToken, url, body, onResponse, eitherDefaultOrDecoder, errorsDecoder } =
    Http.request
        { method =
            case method of
                GET ->
                    "GET"

                POST ->
                    "POST"

                PUT ->
                    "PUT"

                DELETE ->
                    "DELETE"
        , headers =
            case maybeToken of
                Nothing ->
                    []

                Just token ->
                    [ Token.toAuthorizationHeader token ]
        , url = url
        , body = body
        , expect = expectJson onResponse eitherDefaultOrDecoder errorsDecoder
        , timeout = Just oneMinute
        , tracker = Nothing
        }


oneMinute : Float
oneMinute =
    1000 * 60


buildUrl : Url -> List String -> List UB.QueryParameter -> List (Maybe UB.QueryParameter) -> String
buildUrl baseUrl pathSegments requiredParameters optionalParameters =
    UB.crossOrigin
        (Url.toString baseUrl)
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


errorToString : Error () -> String
errorToString error =
    case error of
        BadUrl url ->
            "Bad URL: " ++ url

        Timeout ->
            "Timeout"

        NetworkError ->
            "Network error"

        BadStatus statusCode ->
            "Bad status: " ++ String.fromInt statusCode

        BadBody statusCode decoderError ->
            "Bad body: " ++ String.fromInt statusCode ++ ", " ++ decoderError

        Unauthorized ->
            "Unauthorized"

        NotFound ->
            "Not found"

        UserError () ->
            "Unexpected error"


expectJson : (Result (Error e) a -> msg) -> Either a (JD.Decoder a) -> JD.Decoder e -> Http.Expect msg
expectJson toMsg eitherDefaultOrDecoder errorsDecoder =
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
                    case eitherDefaultOrDecoder of
                        Either.Left default ->
                            Ok default

                        Either.Right decoder ->
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


type alias FormModel model =
    { model
        | errorMessages : List String
        , isDisabled : Bool
    }


handleFormResponse : (a -> ( FormModel model, Cmd msg )) -> FormModel model -> Result (Error (List String)) a -> ( FormModel model, Cmd msg )
handleFormResponse onOk model result =
    --
    -- Handles form errors returned by the formErrorsDecoder.
    --
    case result of
        Ok a ->
            onOk a

        Err err ->
            let
                newModel =
                    { model | isDisabled = False }
            in
            case err of
                UserError errorMessages ->
                    ( { newModel | errorMessages = errorMessages }
                    , Cmd.none
                    )

                _ ->
                    ( { newModel | errorMessages = [ "An unexpected error occurred" ] }
                    , Cmd.none
                    )
