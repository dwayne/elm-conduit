module Main exposing (main)

import Browser as B
import Browser.Navigation exposing (Key)
import Html as H
import Route
import Url exposing (Url)


main : Program Flags Model Msg
main =
    B.application
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        }


type alias Flags =
    ()



-- MODEL


type alias Model =
    { url : Url
    , key : Key
    , page : Page
    }


type Page
    = Home
    | SignIn
    | SignUp
    | Settings
    | Editor
    | Article
    | Profile
    | NotFound


init : Flags -> Url -> Key -> ( Model, Cmd msg )
init _ url key =
    ( { url = url
      , key = key
      , page = getPageFromUrl url
      }
    , Cmd.none
    )


getPageFromUrl : Url -> Page
getPageFromUrl url =
    case Route.fromUrl url of
        Just Route.Home ->
            Home

        Just Route.Login ->
            SignIn

        Just Route.Register ->
            SignUp

        Just Route.Settings ->
            Settings

        Just Route.CreateArticle ->
            Editor

        Just (Route.EditArticle _) ->
            Editor

        Just (Route.Article _) ->
            Article

        Just (Route.Profile _ _) ->
            Profile

        Nothing ->
            NotFound



-- UPDATE


type Msg
    = ClickedLink B.UrlRequest
    | ChangedUrl Url


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        ClickedLink _ ->
            ( model
            , Cmd.none
            )

        ChangedUrl url ->
            ( changeUrl url model
            , Cmd.none
            )


changeUrl : Url -> Model -> Model
changeUrl url model =
    { model
        | url = url
        , page = getPageFromUrl url
    }



-- VIEW


view : Model -> B.Document msg
view { url } =
    { title = "Conduit"
    , body =
        [ H.text <| "url = " ++ Url.toString url
        ]
    }
