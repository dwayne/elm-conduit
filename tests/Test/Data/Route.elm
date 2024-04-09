module Test.Data.Route exposing (suite)

import Data.Route as Route
import Data.Slug as Slug
import Data.Username as Username
import Expect
import Test exposing (Test, describe, test)
import Url


suite : Test
suite =
    describe "Data.Route"
        [ fromUrlSuite
        ]


fromUrlSuite : Test
fromUrlSuite =
    let
        examples =
            --
            -- [ ( path, maybeRoute ), ... ]
            --
            [ ( "/", Just Route.Home )
            , ( "/login", Just Route.Login )
            , ( "/register", Just Route.Register )
            , ( "/settings", Just Route.Settings )
            , ( "/editor", Just Route.CreateArticle )
            , ( "/editor/article-1"
              , Maybe.map Route.EditArticle (Slug.fromString "article-1")
              )
            , ( "/article/article-2"
              , Maybe.map Route.Article (Slug.fromString "article-2")
              )
            , ( "/article/my article"
              , Maybe.map Route.Article (Slug.fromString "my article")
              )
            , ( "/article/my%20article"
              , Maybe.map Route.Article (Slug.fromString "my article")
              )
            , ( "/profile/eric-simons"
              , Maybe.map Route.Profile (Username.fromString "eric-simons")
              )
            , ( "/profile/Eric Simons"
              , Maybe.map Route.Profile (Username.fromString "Eric Simons")
              )
            , ( "/profile/Eric%20Simons"
              , Maybe.map Route.Profile (Username.fromString "Eric Simons")
              )
            , ( "/profile/eric-simons/favourites"
              , Maybe.map Route.Favourites (Username.fromString "eric-simons")
              )
            ]
    in
    describe "fromUrl" <|
        List.map
            (\( path, maybeRoute ) ->
                test path <|
                    \_ ->
                        let
                            urlString =
                                "https://elm-conduit.dev" ++ path

                            maybeUrl =
                                Url.fromString urlString
                        in
                        case maybeUrl of
                            Just url ->
                                Route.fromUrl url
                                    |> Expect.equal maybeRoute

                            Nothing ->
                                Expect.fail <| "Bad URL: " ++ urlString
            )
            examples
