module Lib.Json.Decode exposing (url)

import Json.Decode as JD
import Url exposing (Url)


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
