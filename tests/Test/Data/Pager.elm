module Test.Data.Pager exposing (suite)

import Data.Offset as Offset
import Data.PageNumber as PageNumber
import Data.Pager as Pager exposing (Pager)
import Data.Total as Total
import Expect
import Test exposing (Test, describe, test)



--
-- N.B.: In all the test cases below we use a page limit of 5.
--


suite : Test
suite =
    describe "Data.Pager"
        [ toTotalPagesSuite
        , toPageSuite
        ]


toTotalPagesSuite : Test
toTotalPagesSuite =
    let
        examples =
            --
            -- [ ( totalItems, totalPages ), ... ]
            --
            [ ( 0, 0 )
            , ( 1, 1 )
            , ( 2, 1 )
            , ( 3, 1 )
            , ( 4, 1 )
            , ( 5, 1 )
            , ( 6, 2 )
            , ( 7, 2 )
            , ( 8, 2 )
            , ( 9, 2 )
            , ( 10, 2 )
            , ( 11, 3 )
            , ( 20, 4 )
            , ( 21, 5 )
            , ( 100, 20 )
            ]
    in
    describe "toTotalPages" <|
        List.map
            (\( totalItems, totalPages ) ->
                let
                    description =
                        "{ totalItems = " ++ String.fromInt totalItems ++ ", totalPages = " ++ String.fromInt totalPages ++ " }"
                in
                test description <|
                    \_ ->
                        newPager totalItems
                            |> toTotalPages
                            |> Expect.equal totalPages
            )
            examples


toPageSuite : Test
toPageSuite =
    let
        pager =
            --
            -- 20 pages
            --
            newPager 100

        examples =
            --
            -- [ ( pageNumber, offset ), ... ]
            --
            [ ( 1, 0 )
            , ( 2, 5 )
            , ( 3, 10 )
            , ( 4, 15 )
            , ( 20, 95 )

            --
            -- N.B. Even though page 21 doesn't exist we can still compute the offset.
            --
            , ( 21, 100 )
            ]
    in
    describe "toPage" <|
        List.map
            (\( pageNumber, offset ) ->
                let
                    description =
                        "{ pageNumber = " ++ String.fromInt pageNumber ++ ", offset = " ++ String.fromInt offset ++ " }"
                in
                test description <|
                    \_ ->
                        pager
                            |> toOffset pageNumber
                            |> Expect.equal offset
            )
            examples



-- HELPERS


newPager : Int -> Pager
newPager n =
    let
        totalItems =
            Total.fromInt n
    in
    Pager.five
        |> Pager.setTotalPages totalItems


toTotalPages : Pager -> Int
toTotalPages =
    Pager.toTotalPages >> Total.toInt


toOffset : Int -> Pager -> Int
toOffset n =
    let
        pageNumber =
            PageNumber.fromInt n
    in
    Pager.toPage pageNumber >> .offset >> Offset.toInt
