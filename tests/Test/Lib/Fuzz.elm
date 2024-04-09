module Test.Lib.Fuzz exposing (onlyAsciiWhitespace)

import Fuzz exposing (Fuzzer)


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
