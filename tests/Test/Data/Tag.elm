module Test.Data.Tag exposing (suite)

import Data.Tag as Tag exposing (Tag)
import Expect
import Fuzz exposing (Fuzzer)
import Json.Decode as JD
import Json.Encode as JE
import Test exposing (Test, describe, fuzz, test)
import Test.Lib.Fuzz as Fuzz


suite : Test
suite =
    describe "Data.Tag"
        [ fromStringSuite
        , decoderSuite
        ]


fromStringSuite : Test
fromStringSuite =
    describe "fromString"
        [ fuzz Fuzz.onlyAsciiWhitespace "no empty tags" <|
            \ws ->
                Tag.fromString ws
                    |> Expect.equal Nothing
        , describe "non-empty tags" <|
            List.map
                (\input ->
                    test input <|
                        \_ ->
                            Tag.fromString input
                                |> Maybe.map Tag.toString
                                |> Expect.equal (Just input)
                )
                [ "Agda"
                , "Basic"
                , "Crystal"
                , "D"
                , "Elm"
                ]
        , test "it removes leading and trailing whitespace" <|
            \_ ->
                Tag.fromString " Elm "
                    |> Maybe.map Tag.toString
                    |> Expect.equal (Just "Elm")
        ]


decoderSuite : Test
decoderSuite =
    describe "decoder"
        [ fuzz tagFuzzer "works with any string" <|
            \( input, value ) ->
                case JD.decodeValue tagDecoder value of
                    Ok tag ->
                        Tag.toString tag
                            |> Expect.equal input

                    Err error ->
                        Expect.fail <| JD.errorToString error
        ]


tagFuzzer : Fuzzer ( String, JE.Value )
tagFuzzer =
    Fuzz.string
        |> Fuzz.map
            (\tag ->
                ( tag
                , JE.object
                    [ ( "tag", JE.string tag )
                    ]
                )
            )


tagDecoder : JD.Decoder Tag
tagDecoder =
    JD.field "tag" Tag.decoder
