module Lib.Json.Decode exposing (nullableString, url)

import Json.Decode as JD
import Url exposing (Url)


nullableString : JD.Decoder String
nullableString =
    JD.string
        |> JD.nullable
        |> JD.map (Maybe.withDefault "")


url : JD.Decoder Url
url =
    JD.string
        |> JD.andThen
            (\s ->
                case Url.fromString s of
                    Just validUrl ->
                        JD.succeed validUrl

                    Nothing ->
                        JD.fail <| "Expected a URL: " ++ s
            )
