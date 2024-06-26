module Data.Password exposing
    ( Error(..)
    , Password
    , encode
    , fromString
    )

import Json.Encode as JE


type Password
    = Password String


type Error
    = Blank
    | TooShort Int


fromString : String -> Result Error Password
fromString s =
    let
        t =
            String.trim s
    in
    if String.isEmpty t then
        Err Blank

    else if String.length t < 6 then
        Err <| TooShort 6

    else
        Ok <| Password t


encode : Password -> JE.Value
encode (Password password) =
    JE.string password
