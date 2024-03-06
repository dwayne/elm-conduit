module Main exposing (main)

import Api
import Api.GetUser as GetUser
import Browser as B
import Browser.Navigation as BN
import Data.Config as Config
import Data.Route as Route exposing (Route)
import Data.Token exposing (Token)
import Data.User exposing (User)
import Data.Viewer as Viewer exposing (Viewer)
import Html as H
import Json.Decode as JD
import Page.Home as HomePage
import Page.Login as LoginPage
import Page.Register as RegisterPage
import Port.Action
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



-- FLAGS


type alias Flags =
    JD.Value



-- MODEL


type Model
    = LoadingUser LoadingUserModel
    | Success SuccessModel
    | Failure Error


type alias LoadingUserModel =
    { apiUrl : String
    , url : Url
    , key : BN.Key
    , zone : Time.Zone
    }


type alias SuccessModel =
    { apiUrl : String
    , url : Url
    , key : BN.Key
    , zone : Time.Zone
    , viewer : Viewer
    , page : Page
    }


type Page
    = Home HomePage.Model
    | Login LoginPage.Model
    | Register RegisterPage.Model
    | Settings
    | Editor
    | Article
    | Profile
    | NotFound


type Error
    = BadConfig JD.Error


withModel :
    { onLoadingUser : LoadingUserModel -> a
    , onSuccess : SuccessModel -> a
    , onFailure : Error -> a
    }
    -> Model
    -> a
withModel { onLoadingUser, onSuccess, onFailure } model =
    case model of
        LoadingUser subModel ->
            onLoadingUser subModel

        Success subModel ->
            onSuccess subModel

        Failure error ->
            onFailure error


withLoadingUserModel :
    { onLoadingUser : LoadingUserModel -> a
    , default : a
    }
    -> Model
    -> a
withLoadingUserModel { onLoadingUser, default } =
    withModel
        { onLoadingUser = onLoadingUser
        , onSuccess = always default
        , onFailure = always default
        }


withSuccessModel :
    { onSuccess : SuccessModel -> a
    , default : a
    }
    -> Model
    -> a
withSuccessModel { onSuccess, default } =
    withModel
        { onLoadingUser = always default
        , onSuccess = onSuccess
        , onFailure = always default
        }


init : Flags -> Url -> BN.Key -> ( Model, Cmd Msg )
init flags url key =
    case JD.decodeValue Config.decoder flags of
        Ok { apiUrl, resultMaybeToken } ->
            case resultMaybeToken of
                Ok (Just token) ->
                    initLoadingUser
                        { apiUrl = apiUrl
                        , url = url
                        , key = key
                        , token = token
                        }

                Ok Nothing ->
                    initSuccess
                        { apiUrl = apiUrl
                        , url = url
                        , key = key
                        , maybeZone = Nothing
                        , viewer = Viewer.Guest
                        }

                Err (Config.BadToken error) ->
                    initSuccess
                        { apiUrl = apiUrl
                        , url = url
                        , key = key
                        , maybeZone = Nothing
                        , viewer = Viewer.Guest
                        }
                        |> Debug.log (JD.errorToString error)

        Err error ->
            ( Failure (BadConfig error)
            , Cmd.none
            )


initLoadingUser :
    { apiUrl : String
    , url : Url
    , key : BN.Key
    , token : Token
    }
    -> ( Model, Cmd Msg )
initLoadingUser { apiUrl, url, key, token } =
    ( LoadingUser
        { apiUrl = apiUrl
        , url = url
        , key = key
        , zone = Time.utc
        }
    , Cmd.batch
        [ getZone
        , GetUser.getUser
            apiUrl
            { token = token
            , onResponse = GotUserResponse
            }
        ]
    )


initSuccess :
    { apiUrl : String
    , url : Url
    , key : BN.Key
    , maybeZone : Maybe Time.Zone
    , viewer : Viewer
    }
    -> ( Model, Cmd Msg )
initSuccess { apiUrl, url, key, maybeZone, viewer } =
    let
        ( zone, zoneCmd ) =
            case maybeZone of
                Nothing ->
                    ( Time.utc, getZone )

                Just givenZone ->
                    ( givenZone, Cmd.none )

        ( page, pageCmd ) =
            getPageFromUrl apiUrl viewer url
    in
    ( Success
        { apiUrl = apiUrl
        , url = url
        , key = key
        , zone = zone
        , viewer = viewer
        , page = page
        }
    , Cmd.batch
        [ zoneCmd
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
            ( Login LoginPage.init, Cmd.none )

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
    = GotUserResponse (Result (Api.Error ()) User)
    | ClickedLink B.UrlRequest
    | ChangedUrl Url
    | GotZone Time.Zone
    | LoggedIn User
    | Registered User
    | ChangedPage PageMsg


type PageMsg
    = ChangedHomePage HomePage.Msg
    | ChangedLoginPage LoginPage.Msg
    | ChangedRegisterPage RegisterPage.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotUserResponse result ->
            handleUserResponse result model

        ClickedLink urlRequest ->
            case urlRequest of
                B.Internal url ->
                    pushUrl url model

                B.External url ->
                    loadUrl url model

        ChangedUrl url ->
            changeUrl url model

        GotZone zone ->
            setZone zone model

        LoggedIn user ->
            loginUser user model

        Registered user ->
            loginUser user model

        ChangedPage pageMsg ->
            updatePage pageMsg model


handleUserResponse : Result (Api.Error ()) User -> Model -> ( Model, Cmd Msg )
handleUserResponse result model =
    withLoadingUserModel
        { onLoadingUser =
            \{ apiUrl, url, key, zone } ->
                case result of
                    Ok user ->
                        initSuccess
                            { apiUrl = apiUrl
                            , url = url
                            , key = key
                            , maybeZone = Just zone
                            , viewer = Viewer.User user
                            }

                    Err error ->
                        initSuccess
                            { apiUrl = apiUrl
                            , url = url
                            , key = key
                            , maybeZone = Just zone
                            , viewer = Viewer.Guest
                            }
                            |> Debug.log ("Unable to get the user: " ++ Debug.toString error)
        , default = ( model, Cmd.none )
        }
        model


pushUrl : Url -> Model -> ( Model, Cmd msg )
pushUrl url model =
    ( model
    , withSuccessModel
        { onSuccess = \{ key } -> BN.pushUrl key (Url.toString url)
        , default = Cmd.none
        }
        model
    )


loadUrl : String -> Model -> ( Model, Cmd msg )
loadUrl url model =
    ( model
    , BN.load url
    )


changeUrl : Url -> Model -> ( Model, Cmd Msg )
changeUrl url model =
    withSuccessModel
        { onSuccess =
            \subModel ->
                let
                    ( page, cmd ) =
                        getPageFromUrl subModel.apiUrl subModel.viewer url
                in
                ( Success { subModel | url = url, page = page }
                , cmd
                )
        , default = ( model, Cmd.none )
        }
        model


setZone : Time.Zone -> Model -> ( Model, Cmd msg )
setZone zone model =
    ( withModel
        { onLoadingUser = \subModel -> LoadingUser { subModel | zone = zone }
        , onSuccess = \subModel -> Success { subModel | zone = zone }
        , onFailure = always model
        }
        model
    , Cmd.none
    )


loginUser : User -> Model -> ( Model, Cmd Msg )
loginUser user model =
    withSuccessModel
        { onSuccess =
            \subModel ->
                ( Success { subModel | viewer = Viewer.User user }
                , Cmd.batch
                    [ Port.Action.saveToken user.token
                    , Route.redirectToHome subModel.key
                    ]
                )
        , default = ( model, Cmd.none )
        }
        model


updatePage : PageMsg -> Model -> ( Model, Cmd Msg )
updatePage msg model =
    let
        updatePageHelper subModel =
            case msg of
                ChangedHomePage pageMsg ->
                    updateHomePage pageMsg subModel

                ChangedLoginPage pageMsg ->
                    updateLoginPage pageMsg subModel

                ChangedRegisterPage pageMsg ->
                    updateRegisterPage pageMsg subModel
    in
    withSuccessModel
        { onSuccess = updatePageHelper >> Tuple.mapFirst Success
        , default = ( model, Cmd.none )
        }
        model


updateHomePage : HomePage.Msg -> SuccessModel -> ( SuccessModel, Cmd Msg )
updateHomePage pageMsg subModel =
    case subModel.page of
        Home pageModel ->
            let
                ( newPageModel, newPageCmd ) =
                    HomePage.update
                        { apiUrl = subModel.apiUrl
                        , viewer = subModel.viewer
                        , onChange = ChangedPage << ChangedHomePage
                        }
                        pageMsg
                        pageModel
            in
            ( { subModel | page = Home newPageModel }
            , newPageCmd
            )

        _ ->
            ( subModel, Cmd.none )


updateLoginPage : LoginPage.Msg -> SuccessModel -> ( SuccessModel, Cmd Msg )
updateLoginPage pageMsg subModel =
    case subModel.page of
        Login pageModel ->
            let
                ( newPageModel, newPageCmd ) =
                    LoginPage.update
                        { apiUrl = subModel.apiUrl
                        , onLoggedIn = LoggedIn
                        , onChange = ChangedPage << ChangedLoginPage
                        }
                        pageMsg
                        pageModel
            in
            ( { subModel | page = Login newPageModel }
            , newPageCmd
            )

        _ ->
            ( subModel, Cmd.none )


updateRegisterPage : RegisterPage.Msg -> SuccessModel -> ( SuccessModel, Cmd Msg )
updateRegisterPage pageMsg subModel =
    case subModel.page of
        Register pageModel ->
            let
                ( newPageModel, newPageCmd ) =
                    RegisterPage.update
                        { apiUrl = subModel.apiUrl
                        , onRegistered = Registered
                        , onChange = ChangedPage << ChangedRegisterPage
                        }
                        pageMsg
                        pageModel
            in
            ( { subModel | page = Register newPageModel }
            , newPageCmd
            )

        _ ->
            ( subModel, Cmd.none )



-- VIEW


view : Model -> B.Document Msg
view model =
    { title = "Conduit"
    , body =
        [ withModel
            { onLoadingUser = viewLoadingUserPage
            , onSuccess = viewSuccessPage
            , onFailure = viewFailurePage
            }
            model
        ]
    }


viewLoadingUserPage : LoadingUserModel -> H.Html msg
viewLoadingUserPage _ =
    H.text ""


viewSuccessPage : SuccessModel -> H.Html Msg
viewSuccessPage { url, zone, viewer, page } =
    case page of
        Home model ->
            HomePage.view
                { zone = zone
                , viewer = viewer
                , onChange = ChangedPage << ChangedHomePage
                }
                model

        Login model ->
            LoginPage.view
                { onChange = ChangedPage << ChangedLoginPage
                }
                model

        Register model ->
            RegisterPage.view
                { onChange = ChangedPage << ChangedRegisterPage
                }
                model

        _ ->
            H.text <| "url = " ++ Url.toString url


viewFailurePage : Error -> H.Html msg
viewFailurePage (BadConfig error) =
    H.div
        []
        [ H.h1 [] [ H.text "Configuration Error" ]
        , H.p [] [ H.text "An unexpected configuration error occurred." ]
        , H.p [] [ H.text <| JD.errorToString error ]
        ]
