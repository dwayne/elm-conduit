module Test.Data.Timestamp exposing (suite)

import Data.Timestamp as Timestamp
import Expect
import Test exposing (Test, describe, test)
import Time


suite : Test
suite =
    describe "Data.Timestamp"
        [ toDayStringSuite
        , toTimeStringSuite
        ]


toDayStringSuite : Test
toDayStringSuite =
    describe "toDayString" <|
        List.map
            (\( input, dayString ) ->
                test input <|
                    \_ ->
                        input
                            |> Timestamp.fromString
                            |> Maybe.map (Timestamp.toDayString Time.utc)
                            |> Expect.equal (Just dayString)
            )
            [ ( "2024-01-01T00:00:00.000Z", "January 1st, 2024" )
            , ( "2024-01-01T23:59:59.999Z", "January 1st, 2024" )
            , ( "2024-02-02T00:00:00.000Z", "February 2nd, 2024" )
            , ( "2024-03-03T00:00:00.000Z", "March 3rd, 2024" )
            , ( "2024-04-04T00:00:00.000Z", "April 4th, 2024" )
            , ( "2024-05-11T00:00:00.000Z", "May 11th, 2024" )
            , ( "2024-06-21T00:00:00.000Z", "June 21st, 2024" )
            , ( "2024-07-31T00:00:00.000Z", "July 31st, 2024" )
            ]


toTimeStringSuite : Test
toTimeStringSuite =
    describe "toTimeString" <|
        List.map
            (\( input, timeString ) ->
                test input <|
                    \_ ->
                        input
                            |> Timestamp.fromString
                            |> Maybe.map (Timestamp.toTimeString Time.utc)
                            |> Expect.equal (Just timeString)
            )
            [ ( "2024-01-01T00:00:00.000Z", "12:00 am" )
            , ( "2024-01-01T00:01:00.000Z", "12:01 am" )
            , ( "2024-01-01T05:10:00.000Z", "5:10 am" )
            , ( "2024-01-01T12:00:00.000Z", "12:00 pm" )
            , ( "2024-01-01T13:02:00.000Z", "1:02 pm" )
            , ( "2024-01-01T23:59:59.999Z", "11:59 pm" )
            ]
