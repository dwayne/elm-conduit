module Test.Data.Password exposing (suite)

import Data.Password as Password
import Expect
import Test exposing (Test, describe, fuzz, test)
import Test.Lib.Fuzz as Fuzz


suite : Test
suite =
    describe "Data.Password"
        [ fromStringSuite
        ]


fromStringSuite : Test
fromStringSuite =
    describe "fromString"
        [ fuzz Fuzz.onlyAsciiWhitespace "Err Blank" <|
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
