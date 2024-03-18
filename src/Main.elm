module Main exposing (main)

import Api
import Api.GetUser as GetUser
import Browser as B
import Browser.Navigation as BN
import Data.Article exposing (Article)
import Data.Config as Config
import Data.Route as Route exposing (Route)
import Data.Slug exposing (Slug)
import Data.Token exposing (Token)
import Data.User exposing (User)
import Data.Viewer as Viewer exposing (Viewer)
import Html as H
import Json.Decode as JD
import Lib.Either as Either
import Lib.Task as Task
import Page.Article as ArticlePage
import Page.Editor as EditorPage
import Page.Home as HomePage
import Page.Login as LoginPage
import Page.Register as RegisterPage
import Page.Settings as SettingsPage
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
    { apiUrl : Url
    , url : Url
    , key : BN.Key
    , zone : Time.Zone
    }


type alias SuccessModel =
    { apiUrl : Url
    , url : Url
    , key : BN.Key
    , zone : Time.Zone
    , viewer : Viewer
    , page : Page
    , maybeArticle : Maybe Article
    }


type Page
    = Home HomePage.Model
    | Login LoginPage.Model
    | Register RegisterPage.Model
    | Settings SettingsPage.Model
    | Editor EditorPage.Model
    | Article ArticlePage.Model
    | Profile
    | NotAuthorized
    | NotFound


type Error
    = BadConfig JD.Error


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
    { apiUrl : Url
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
    { apiUrl : Url
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
            getPageFromUrl apiUrl viewer Nothing url
    in
    ( Success
        { apiUrl = apiUrl
        , url = url
        , key = key
        , zone = zone
        , viewer = viewer
        , page = page
        , maybeArticle = Nothing
        }
    , Cmd.batch
        [ zoneCmd
        , pageCmd
        ]
    )


getZone : Cmd Msg
getZone =
    Task.perform GotZone Time.here


getPageFromUrl : Url -> Viewer -> Maybe Article -> Url -> ( Page, Cmd Msg )
getPageFromUrl apiUrl viewer maybeArticle url =
    case Route.fromUrl url of
        Just route ->
            getPageFromRoute apiUrl viewer maybeArticle route

        Nothing ->
            ( NotFound, Cmd.none )


getPageFromRoute : Url -> Viewer -> Maybe Article -> Route -> ( Page, Cmd Msg )
getPageFromRoute apiUrl viewer maybeArticle route =
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
            withAuthForPage
                (\user ->
                    ( Settings <|
                        SettingsPage.init
                            { imageUrl = user.imageUrl
                            , username = user.username
                            , bio = user.bio
                            , email = user.email
                            }
                    , Cmd.none
                    )
                )
                viewer

        Route.CreateArticle ->
            getEditorPage apiUrl viewer Nothing

        Route.EditArticle slug ->
            getEditorPage apiUrl viewer <| Just slug

        Route.Article slug ->
            let
                ( eitherSlugOrArticle, usedCmd ) =
                    case maybeArticle of
                        Just article ->
                            ( if article.slug == slug then
                                Either.Right article

                              else
                                Either.Left slug
                            , Task.dispatch UsedArticleCache
                            )

                        Nothing ->
                            ( Either.Left slug
                            , Cmd.none
                            )

                ( model, initCmd ) =
                    ArticlePage.init
                        { apiUrl = apiUrl
                        , viewer = viewer
                        , eitherSlugOrArticle = eitherSlugOrArticle
                        , onChange = ChangedPage << ChangedArticlePage
                        }
            in
            ( Article model
            , Cmd.batch
                [ usedCmd
                , initCmd
                ]
            )

        Route.Profile _ ->
            ( Profile, Cmd.none )

        Route.Favourites _ ->
            ( Profile, Cmd.none )


getEditorPage : Url -> Viewer -> Maybe Slug -> ( Page, Cmd Msg )
getEditorPage apiUrl viewer maybeSlug =
    withAuthForPage
        (\user ->
            let
                ( model, cmd ) =
                    EditorPage.init
                        { apiUrl = apiUrl
                        , token = user.token
                        , maybeSlug = maybeSlug
                        , onChange = ChangedPage << ChangedEditorPage
                        }
            in
            ( Editor model
            , cmd
            )
        )
        viewer



-- UPDATE


type Msg
    = GotUserResponse (Result (Api.Error ()) User)
    | ClickedLink B.UrlRequest
    | ChangedUrl Url
    | GotZone Time.Zone
    | Registered User
    | LoggedIn User
    | LoggedOut
    | UpdatedUser User
    | PublishedArticle Article
    | UsedArticleCache
    | DeletedArticle
    | ChangedPage PageMsg


type PageMsg
    = ChangedHomePage HomePage.Msg
    | ChangedLoginPage LoginPage.Msg
    | ChangedRegisterPage RegisterPage.Msg
    | ChangedSettingsPage SettingsPage.Msg
    | ChangedEditorPage EditorPage.Msg
    | ChangedArticlePage ArticlePage.Msg


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

        Registered user ->
            loginUser user model

        LoggedIn user ->
            loginUser user model

        LoggedOut ->
            logout model

        UpdatedUser user ->
            updateUser user model

        PublishedArticle article ->
            showArticle article model

        UsedArticleCache ->
            clearArticleCache model

        DeletedArticle ->
            handleDeletedArticle model

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
pushUrl url =
    withSuccessModel
        (\subModel ->
            ( subModel
            , BN.pushUrl subModel.key (Url.toString url)
            )
        )


loadUrl : String -> Model -> ( Model, Cmd msg )
loadUrl url model =
    ( model
    , BN.load url
    )


changeUrl : Url -> Model -> ( Model, Cmd Msg )
changeUrl url =
    withSuccessModel
        (\subModel ->
            let
                ( page, cmd ) =
                    getPageFromUrl subModel.apiUrl subModel.viewer subModel.maybeArticle url
            in
            ( { subModel | url = url, page = page }
            , cmd
            )
        )


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
loginUser user =
    withSuccessModel
        (\subModel ->
            ( { subModel | viewer = Viewer.User user }
            , Cmd.batch
                [ Port.Action.saveToken user.token
                , Route.redirectToHome subModel.key
                ]
            )
        )


logout : Model -> ( Model, Cmd Msg )
logout =
    withSuccessModel
        (\subModel ->
            ( { subModel | viewer = Viewer.Guest }
            , Cmd.batch
                [ Port.Action.deleteToken
                , Route.redirectToHome subModel.key
                ]
            )
        )


updateUser : User -> Model -> ( Model, Cmd Msg )
updateUser user =
    withSuccessModel
        (\subModel ->
            ( { subModel | viewer = Viewer.User user }
            , Port.Action.saveToken user.token
            )
        )


showArticle : Article -> Model -> ( Model, Cmd Msg )
showArticle article =
    withSuccessModel
        (\subModel ->
            ( { subModel | maybeArticle = Just article }
            , Route.redirectToArticle subModel.key article.slug
            )
        )


clearArticleCache : Model -> ( Model, Cmd Msg )
clearArticleCache =
    withSuccessModel
        (\subModel ->
            ( { subModel | maybeArticle = Nothing }
            , Cmd.none
            )
        )


handleDeletedArticle : Model -> ( Model, Cmd Msg )
handleDeletedArticle =
    withSuccessModel
        (\subModel ->
            ( subModel
            , Route.redirectToHome subModel.key
            )
        )


updatePage : PageMsg -> Model -> ( Model, Cmd Msg )
updatePage msg =
    withSuccessModel
        (\subModel ->
            case msg of
                ChangedHomePage pageMsg ->
                    updateHomePage pageMsg subModel

                ChangedLoginPage pageMsg ->
                    updateLoginPage pageMsg subModel

                ChangedRegisterPage pageMsg ->
                    updateRegisterPage pageMsg subModel

                ChangedSettingsPage pageMsg ->
                    updateSettingsPage pageMsg subModel

                ChangedEditorPage pageMsg ->
                    updateEditorPage pageMsg subModel

                ChangedArticlePage pageMsg ->
                    updateArticlePage pageMsg subModel
        )


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


updateSettingsPage : SettingsPage.Msg -> SuccessModel -> ( SuccessModel, Cmd Msg )
updateSettingsPage pageMsg subModel =
    case subModel.page of
        Settings pageModel ->
            withAuthForUpdate
                (\user ->
                    let
                        ( newPageModel, newPageCmd ) =
                            SettingsPage.update
                                { apiUrl = subModel.apiUrl
                                , token = user.token
                                , onUpdatedUser = UpdatedUser
                                , onChange = ChangedPage << ChangedSettingsPage
                                }
                                pageMsg
                                pageModel
                    in
                    ( { subModel | page = Settings newPageModel }
                    , newPageCmd
                    )
                )
                subModel

        _ ->
            ( subModel, Cmd.none )


updateEditorPage : EditorPage.Msg -> SuccessModel -> ( SuccessModel, Cmd Msg )
updateEditorPage pageMsg subModel =
    case subModel.page of
        Editor pageModel ->
            withAuthForUpdate
                (\user ->
                    let
                        ( newPageModel, newPageCmd ) =
                            EditorPage.update
                                { apiUrl = subModel.apiUrl
                                , token = user.token
                                , onPublish = PublishedArticle
                                , onChange = ChangedPage << ChangedEditorPage
                                }
                                pageMsg
                                pageModel
                    in
                    ( { subModel | page = Editor newPageModel }
                    , newPageCmd
                    )
                )
                subModel

        _ ->
            ( subModel, Cmd.none )


updateArticlePage : ArticlePage.Msg -> SuccessModel -> ( SuccessModel, Cmd Msg )
updateArticlePage pageMsg subModel =
    case subModel.page of
        Article pageModel ->
            let
                ( newPageModel, newPageCmd ) =
                    ArticlePage.update
                        { apiUrl = subModel.apiUrl
                        , onDeleteArticle = DeletedArticle
                        , onChange = ChangedPage << ChangedArticlePage
                        }
                        pageMsg
                        pageModel
            in
            ( { subModel | page = Article newPageModel }
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

        Settings model ->
            withAuthForView
                (\user ->
                    SettingsPage.view
                        { user = user
                        , onLogout = LoggedOut
                        , onChange = ChangedPage << ChangedSettingsPage
                        }
                        model
                )
                viewer

        Editor model ->
            withAuthForView
                (\user ->
                    EditorPage.view
                        { user = user
                        , onChange = ChangedPage << ChangedEditorPage
                        }
                        model
                )
                viewer

        Article model ->
            ArticlePage.view
                { zone = zone
                , viewer = viewer
                , onChange = ChangedPage << ChangedArticlePage
                }
                model

        Profile ->
            H.text "You are on the profile page."

        NotAuthorized ->
            H.text "You are not allowed to view this page."

        NotFound ->
            H.text "The page you are looking for does not exist."


viewFailurePage : Error -> H.Html msg
viewFailurePage (BadConfig error) =
    H.div
        []
        [ H.h1 [] [ H.text "Configuration Error" ]
        , H.p [] [ H.text "An unexpected configuration error occurred." ]
        , H.p [] [ H.text <| JD.errorToString error ]
        ]



-- HELPERS


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


withSuccessModel : (SuccessModel -> ( SuccessModel, Cmd msg )) -> Model -> ( Model, Cmd msg )
withSuccessModel onSuccess model =
    let
        default =
            ( model, Cmd.none )
    in
    withModel
        { onLoadingUser = always default
        , onSuccess = Tuple.mapFirst Success << onSuccess
        , onFailure = always default
        }
        model


withAuthForPage : (User -> ( Page, Cmd Msg )) -> Viewer -> ( Page, Cmd Msg )
withAuthForPage toPage viewer =
    case viewer of
        Viewer.Guest ->
            ( NotAuthorized, Cmd.none )

        Viewer.User user ->
            toPage user


withAuthForUpdate : (User -> ( SuccessModel, Cmd Msg )) -> SuccessModel -> ( SuccessModel, Cmd Msg )
withAuthForUpdate toModel subModel =
    case subModel.viewer of
        Viewer.Guest ->
            ( subModel, Cmd.none )

        Viewer.User user ->
            toModel user


withAuthForView : (User -> H.Html msg) -> Viewer -> H.Html msg
withAuthForView toView viewer =
    case viewer of
        Viewer.Guest ->
            H.text "You are not allowed to view this page."

        Viewer.User user ->
            toView user
