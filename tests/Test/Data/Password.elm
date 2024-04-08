module Test.Data.Password exposing (suite)

import Data.Password as Password
import Expect
import Fuzz exposing (Fuzzer)
import Test exposing (Test, describe, fuzz, test)


suite : Test
suite =
    describe "Data.Password"
        [ fromStringSuite
        ]


fromStringSuite : Test
fromStringSuite =
    describe "fromString"
        [ fuzz onlyAsciiWhitespace "Err Blank" <|
            \ws ->
                Password.fromString ws
                    |> Expect.equal (Err Password.Blank)
        , describe "Err TooShort" <|
            List.map
                (\input ->
                    let
                        description =
                            "password = " ++ input
                    in
                    test description <|
                        \_ ->
                            Password.fromString input
                                |> Expect.equal (Err <| Password.TooShort 6)
                )
                [ "a"
                , "ab"
                , "abc"
                , "abc1"
                , "abc12"
                ]
        , describe "Ok" <|
            List.map
                (\input ->
                    let
                        description =
                            "password = " ++ input
                    in
                    test description <|
                        \_ ->
                            Password.fromString input
                                |> Expect.ok
                )
                [ "abc123"
                , "123456"
                , "password"
                , "pa5$w0rD!"
                ]
        ]



-- FUZZERS


onlyAsciiWhitespace : Fuzzer String
onlyAsciiWhitespace =
    --
    -- https://www.ascii-code.com/characters/white-space-characters
    --
    [ 9 -- Horizontal Tab
    , 10 -- Line Feed
    , 11 -- Vertical Tabulation
    , 12 -- Form Feed
    , 13 -- Carriage Return
    , 32 -- Space
    ]
        |> List.map Char.fromCode
        |> Fuzz.oneOfValues
        |> Fuzz.list
        |> Fuzz.map String.fromList
