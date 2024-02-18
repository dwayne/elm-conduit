module Main exposing (main)

import Browser as B
import Browser.Navigation as BN
import Data.Route as Route exposing (Route)
import Data.User exposing (User)
import Data.Viewer as Viewer exposing (Viewer)
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
    String



-- MODEL


type alias Model =
    { apiUrl : String
    , url : Url
    , key : BN.Key
    , zone : Time.Zone
    , viewer : Viewer
    , page : Page
    }


type Page
    = Home HomePage.Model
    | Login
    | Register RegisterPage.Model
    | Settings
    | Editor
    | Article
    | Profile
    | NotFound


init : Flags -> Url -> BN.Key -> ( Model, Cmd Msg )
init apiUrl url key =
    let
        viewer =
            Viewer.Guest

        ( page, pageCmd ) =
            getPageFromUrl apiUrl viewer url
    in
    ( { apiUrl = apiUrl
      , url = url
      , key = key
      , zone = Time.utc
      , viewer = viewer
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


getPageFromUrl : String -> Viewer -> Url -> ( Page, Cmd Msg )
getPageFromUrl apiUrl viewer url =
    case Route.fromUrl url of
        Just route ->
            getPageFromRoute apiUrl viewer route

        Nothing ->
            ( NotFound, Cmd.none )


getPageFromRoute : String -> Viewer -> Route -> ( Page, Cmd Msg )
getPageFromRoute apiUrl viewer route =
    case route of
        Route.Home ->
            let
                ( model, cmd ) =
                    HomePage.init
                        { apiUrl = apiUrl
                        , viewer = viewer
                        , onChange = ChangedPage << ChangedHomePage
                        }
            in
            ( Home model, cmd )

        Route.Login ->
            ( Login, Cmd.none )

        Route.Register ->
            ( Register RegisterPage.init, Cmd.none )

        Route.Settings ->
            ( Settings, Cmd.none )

        Route.CreateArticle ->
            ( Editor, Cmd.none )

        Route.EditArticle _ ->
            ( Editor, Cmd.none )

        Route.Article _ ->
            ( Article, Cmd.none )

        Route.Profile _ _ ->
            ( Profile, Cmd.none )



-- UPDATE


type Msg
    = ClickedLink B.UrlRequest
    | ChangedUrl Url
    | GotZone Time.Zone
    | Registered User
    | ChangedPage PageMsg


type PageMsg
    = ChangedHomePage HomePage.Msg
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

        Registered user ->
            ( { model | viewer = Viewer.User user }
            , Route.redirectToHome model.key
            )

        ChangedPage pageMsg ->
            updatePage pageMsg model


updatePage : PageMsg -> Model -> ( Model, Cmd Msg )
updatePage msg model =
    case msg of
        ChangedHomePage pageMsg ->
            updateHomePage pageMsg model

        ChangedRegisterPage pageMsg ->
            updateRegisterPage pageMsg model


updateHomePage : HomePage.Msg -> Model -> ( Model, Cmd Msg )
updateHomePage pageMsg model =
    case model.page of
        Home pageModel ->
            let
                ( newPageModel, newPageCmd ) =
                    HomePage.update
                        { apiUrl = model.apiUrl
                        , viewer = model.viewer
                        , onChange = ChangedPage << ChangedHomePage
                        }
                        pageMsg
                        pageModel
            in
            ( { model | page = Home newPageModel }
            , newPageCmd
            )

        _ ->
            ( model, Cmd.none )


updateRegisterPage : RegisterPage.Msg -> Model -> ( Model, Cmd Msg )
updateRegisterPage pageMsg model =
    case model.page of
        Register pageModel ->
            let
                ( newPageModel, newPageCmd ) =
                    RegisterPage.update
                        { apiUrl = model.apiUrl
                        , onRegistered = Registered
                        , onChange = ChangedPage << ChangedRegisterPage
                        }
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
            getPageFromUrl model.apiUrl model.viewer url
    in
    ( { model
        | url = url
        , page = page
      }
    , cmd
    )



-- VIEW


view : Model -> B.Document Msg
view model =
    { title = "Conduit"
    , body =
        [ viewPage model
        ]
    }


viewPage : Model -> H.Html Msg
viewPage { url, zone, viewer, page } =
    case page of
        Home model ->
            HomePage.view
                { zone = zone
                , viewer = viewer
                , onChange = ChangedPage << ChangedHomePage
                }
                model

        Register model ->
            RegisterPage.view
                { onChange = ChangedPage << ChangedRegisterPage
                }
                model

        _ ->
            H.text <| "url = " ++ Url.toString url
