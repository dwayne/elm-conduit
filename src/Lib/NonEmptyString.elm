module Lib.NonEmptyString exposing
    ( NonEmptyString
    , decoder
    , fromString
    , toString
    )

import Json.Decode as JD


type NonEmptyString
    = NonEmptyString String


fromString : String -> Maybe NonEmptyString
fromString s =
    let
        t =
            String.trim s
    in
    if String.isEmpty t then
        Nothing

    else
        Just <| NonEmptyString t


decoder : JD.Decoder NonEmptyString
decoder =
    JD.string
        |> JD.andThen
            (\s ->
                case fromString s of
                    Just t ->
                        JD.succeed t

                    Nothing ->
                        JD.fail <| "Expected a non-empty string: '" ++ s ++ "'"
            )


toString : NonEmptyString -> String
toString (NonEmptyString t) =
    t
