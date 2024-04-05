module Data.Route exposing
    ( Route(..)
    , fromUrl
    , logoutPath
    , pushUrl
    , redirectToArticle
    , redirectToHome
    , toString
    )

import Browser.Navigation as BN
import Data.Slug as Slug exposing (Slug)
import Data.Username as Username exposing (Username)
import Url exposing (Url)
import Url.Builder as UB
import Url.Parser as UP exposing ((</>))


type Route
    = Home
    | Login
    | Register
    | Settings
    | CreateArticle
    | EditArticle Slug
    | Article Slug
    | Profile Username
    | Favourites Username


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
        , UP.map EditArticle (UP.s "editor" </> slugParser)
        , UP.map Article (UP.s "article" </> slugParser)
        , UP.map Profile (UP.s "profile" </> usernameParser)
        , UP.map Favourites (UP.s "profile" </> usernameParser </> UP.s "favourites")
        ]


slugParser : UP.Parser (Slug -> a) a
slugParser =
    UP.custom "SLUG" (Url.percentDecode >> Maybe.andThen Slug.fromString)


usernameParser : UP.Parser (Username -> a) a
usernameParser =
    UP.custom "USERNAME" (Url.percentDecode >> Maybe.andThen Username.fromString)


redirectToHome : BN.Key -> Cmd msg
redirectToHome key =
    replaceUrl key Home


redirectToArticle : BN.Key -> Slug -> Cmd msg
redirectToArticle key =
    replaceUrl key << Article


replaceUrl : BN.Key -> Route -> Cmd msg
replaceUrl key =
    toString >> BN.replaceUrl key


pushUrl : BN.Key -> Route -> Cmd msg
pushUrl key =
    toString >> BN.pushUrl key


toString : Route -> String
toString route =
    case route of
        Home ->
            UB.absolute [] []

        Login ->
            UB.absolute [ "login" ] []

        Register ->
            UB.absolute [ "register" ] []

        Settings ->
            UB.absolute [ "settings" ] []

        CreateArticle ->
            UB.absolute [ "editor" ] []

        EditArticle slug ->
            UB.absolute [ "editor", Slug.toString slug ] []

        Article slug ->
            UB.absolute [ "article", Slug.toString slug ] []

        Profile username ->
            UB.absolute [ "profile", Username.toString username ] []

        Favourites username ->
            UB.absolute [ "profile", Username.toString username, "favourites" ] []


logoutPath : String
logoutPath =
    UB.absolute [ "logout" ] []
