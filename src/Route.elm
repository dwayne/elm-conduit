module Route exposing
    ( Route(..)
    , Slug
    , Username
    , fromUrl
    )

import Lib.Function exposing (flip)
import Url exposing (Url)
import Url.Parser as UP exposing ((</>))



--
-- TODO:
--
-- 1. Move Route into Data.Route.
-- 2. This module is a good candidate for unit tests.
--


type Route
    = Home
    | Login
    | Register
    | Settings
    | CreateArticle
    | EditArticle Slug
    | Article Slug
    | Profile Username Bool


type alias Slug =
    String


type alias Username =
    String


fromUrl : Url -> Maybe Route
fromUrl =
    UP.parse routeParser


routeParser : UP.Parser (Route -> a) a
routeParser =
    UP.oneOf
        [ UP.map Home UP.top
        , UP.map Login (UP.s "login")
        , UP.map Register (UP.s "register")
        , UP.map Settings (UP.s "settings")
        , UP.map CreateArticle (UP.s "editor")
        , UP.map EditArticle (UP.s "editor" </> UP.string)
        , UP.map Article (UP.s "article" </> UP.string)
        , UP.map (flip Profile False) (UP.s "profile" </> UP.string)
        , UP.map (flip Profile True) (UP.s "profile" </> UP.string </> UP.s "favourites")
        ]
