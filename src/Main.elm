module Main exposing (main)

import Browser as B
import Browser.Navigation as BN exposing (Key)
import Data.Route as Route
import Html as H
import Page.Home as HomePage
import Page.Register as RegisterPage
import Task
import Time
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
    { apiUrl : String
    , url : Url
    , key : Key
    , zone : Time.Zone
    , page : Page
    }


type Page
    = Home HomePage.Model
    | SignIn
    | Register RegisterPage.Model
    | Settings
    | Editor
    | Article
    | Profile
    | NotFound


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init _ url key =
    let
        apiUrl =
            "https://api.realworld.io/api"

        ( page, pageCmd ) =
            getPageFromUrl apiUrl url
    in
    ( { apiUrl = apiUrl
      , url = url
      , key = key
      , zone = Time.utc
      , page = page
      }
    , Cmd.batch
        [ getZone
        , pageCmd
        ]
    )


getZone : Cmd Msg
getZone =
    Task.perform GotZone Time.here


getPageFromUrl : String -> Url -> ( Page, Cmd Msg )
getPageFromUrl apiUrl url =
    case Route.fromUrl url of
        Just Route.Home ->
            let
                ( model, cmd ) =
                    HomePage.init
                        { apiUrl = apiUrl
                        , viewer = HomePage.Guest
                        , onChange = ChangedHomePage
                        }
            in
            ( Home model
            , cmd
            )

        Just Route.Login ->
            ( SignIn, Cmd.none )

        Just Route.Register ->
            ( Register RegisterPage.init, Cmd.none )

        Just Route.Settings ->
            ( Settings, Cmd.none )

        Just Route.CreateArticle ->
            ( Editor, Cmd.none )

        Just (Route.EditArticle _) ->
            ( Editor, Cmd.none )

        Just (Route.Article _) ->
            ( Article, Cmd.none )

        Just (Route.Profile _ _) ->
            ( Profile, Cmd.none )

        Nothing ->
            ( NotFound, Cmd.none )



-- UPDATE


type Msg
    = ClickedLink B.UrlRequest
    | ChangedUrl Url
    | GotZone Time.Zone
    | ChangedHomePage HomePage.Msg
    | ChangedRegisterPage RegisterPage.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink urlRequest ->
            case urlRequest of
                B.Internal url ->
                    ( model
                    , BN.pushUrl model.key (Url.toString url)
                    )

                B.External url ->
                    ( model
                    , BN.load url
                    )

        ChangedUrl url ->
            changeUrl url model

        GotZone zone ->
            ( { model | zone = zone }
            , Cmd.none
            )

        ChangedHomePage pageMsg ->
            case model.page of
                Home pageModel ->
                    let
                        ( newPageModel, newPageCmd ) =
                            HomePage.update
                                { apiUrl = model.apiUrl
                                , onChange = ChangedHomePage
                                }
                                pageMsg
                                pageModel
                    in
                    ( { model | page = Home newPageModel }
                    , newPageCmd
                    )

                _ ->
                    ( model, Cmd.none )

        ChangedRegisterPage pageMsg ->
            case model.page of
                Register pageModel ->
                    let
                        ( newPageModel, newPageCmd ) =
                            RegisterPage.update
                                pageMsg
                                pageModel
                    in
                    ( { model | page = Register newPageModel }
                    , newPageCmd
                    )

                _ ->
                    ( model, Cmd.none )


changeUrl : Url -> Model -> ( Model, Cmd Msg )
changeUrl url model =
    let
        ( page, cmd ) =
            getPageFromUrl model.apiUrl url
    in
    ( { model
        | url = url
        , page = page
      }
    , cmd
    )



-- VIEW


view : Model -> B.Document Msg
view { url, zone, page } =
    { title = "Conduit"
    , body =
        [ viewPage url zone page
        ]
    }


viewPage : Url -> Time.Zone -> Page -> H.Html Msg
viewPage url zone page =
    case page of
        Home model ->
            HomePage.view
                { zone = zone
                , onChange = ChangedHomePage
                }
                model

        Register model ->
            RegisterPage.view
                { onChange = ChangedRegisterPage
                }
                model

        _ ->
            H.text <| "url = " ++ Url.toString url
