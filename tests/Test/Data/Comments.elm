module Test.Data.Comments exposing (suite)

import Data.Comment exposing (Comment)
import Data.Comments as Comments exposing (Comments)
import Data.Timestamp as Timestamp
import Expect
import Fuzz exposing (Fuzzer)
import Json.Decode as JD
import Json.Encode as JE
import Test exposing (Test, describe, fuzz)


suite : Test
suite =
    describe "Data.Comments"
        [ describe "decoder"
            [ fuzz commentsFuzzer "sorts comments in reverse chronological order" <|
                \( n, value ) ->
                    case JD.decodeValue Comments.decoder value of
                        Ok comments ->
                            let
                                listOfComments =
                                    Comments.toList comments
                            in
                            ( List.length listOfComments
                            , isReverseChronological listOfComments
                            )
                                |> Expect.equal ( n, True )

                        Err error ->
                            Expect.fail (JD.errorToString error)
            ]
        ]



-- FUZZERS


commentsFuzzer : Fuzzer ( Int, JE.Value )
commentsFuzzer =
    Fuzz.intRange 0 maxTotalMilliseconds
        |> Fuzz.map (\n -> newComment n (msToTimestamp "2024-01-01" n))
        |> Fuzz.list
        |> Fuzz.map (\l -> ( List.length l, JE.list identity l ))



-- HELPERS


isReverseChronological : List Comment -> Bool
isReverseChronological comments =
    case comments of
        [] ->
            True

        [ _ ] ->
            True

        commentA :: commentB :: restOfComments ->
            case Timestamp.compare commentA.createdAt commentB.createdAt of
                LT ->
                    False

                _ ->
                    isReverseChronological (commentB :: restOfComments)


newComment : Int -> String -> JE.Value
newComment id createdAt =
    JE.object
        [ ( "id", JE.int id )
        , ( "createdAt", JE.string createdAt )
        , ( "body", JE.string "A comment." )
        , ( "author"
          , JE.object
                [ ( "username", JE.string "Eric Simons" )
                , ( "image", JE.string "http://i.imgur.com/Qr71crq.jpg" )
                ]
          )
        ]


maxTotalMilliseconds : Int
maxTotalMilliseconds =
    --
    -- What is the most that totalMillisSeconds (see msToTimestamp) can be?
    --
    --   23 * 3600000 + 59 * 60000 + 59 * 1000 + 999
    --   = 86399999
    --
    86399999


msToTimestamp : String -> Int -> String
msToTimestamp date totalMilliseconds =
    --
    -- Preconditions:
    --
    -- 1. date MUST be in the format YYYY-MM-DD.
    -- 2. 0 <= totalMilliseconds <= maxTotalMilliseconds.
    --
    let
        hrs =
            totalMilliseconds // 3600000

        totalMillisecondsAfterHrs =
            totalMilliseconds |> modBy 3600000

        mins =
            totalMillisecondsAfterHrs // 60000

        totalMillisecondsAfterMins =
            totalMillisecondsAfterHrs |> modBy 60000

        secs =
            totalMillisecondsAfterMins // 1000

        ms =
            totalMillisecondsAfterMins |> modBy 1000
    in
    String.concat
        [ date
        , "T"
        , toNDigits 2 hrs
        , ":"
        , toNDigits 2 mins
        , ":"
        , toNDigits 2 secs
        , "."
        , toNDigits 3 ms
        , "Z"
        ]


toNDigits : Int -> Int -> String
toNDigits n =
    String.fromInt >> String.padLeft n '0'
