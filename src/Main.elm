module Main exposing (main)

import Browser
import Html as H
import Html.Attributes as HA
import View.ArticlePreview as ArticlePreview
import View.Banner as Banner
import View.FeedToggle as FeedToggle
import View.Footer as Footer
import View.Header as Header
import View.Login as Login
import View.LoginForm as LoginForm
import View.Pagination as Pagination
import View.Register as Register
import View.RegisterForm as RegisterForm
import View.Settings as Settings
import View.SettingsForm as SettingsForm
import View.Sidebar as Sidebar


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { homePageModel : HomePageModel
    }


type alias HomePageModel =
    { tag : String
    , active : FeedToggle.Feed
    , isFavourite : Bool
    , currentPage : Int
    }


init : Model
init =
    { homePageModel =
        { tag = ""
        , active = FeedToggle.Global
        , isFavourite = False
        , currentPage = 1
        }
    }



-- UPDATE


type Msg
    = NoOp
    | ClickedFeedToggle FeedToggle.Feed
    | ClickedFavourite Bool
    | ClickedPagination Int
    | ClickedSidebar String


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model

        ClickedFeedToggle feed ->
            let
                homePageModel =
                    model.homePageModel

                newHomePageModel =
                    { homePageModel | active = feed }
            in
            { model | homePageModel = newHomePageModel }

        ClickedFavourite isFavourite ->
            let
                homePageModel =
                    model.homePageModel

                newHomePageModel =
                    { homePageModel | isFavourite = isFavourite }
            in
            { model | homePageModel = newHomePageModel }

        ClickedPagination page ->
            let
                homePageModel =
                    model.homePageModel

                newHomePageModel =
                    { homePageModel | currentPage = page }
            in
            { model | homePageModel = newHomePageModel }

        ClickedSidebar tag ->
            let
                homePageModel =
                    model.homePageModel

                newHomePageModel =
                    { homePageModel
                        | tag = tag
                        , active = FeedToggle.Tag tag
                    }
            in
            { model | homePageModel = newHomePageModel }



-- VIEW


view : Model -> H.Html Msg
view { homePageModel } =
    H.div []
        [ viewHeader
        , viewHomePage homePageModel
        , viewLoginPage
        , viewRegisterPage
        , viewSettingsPage
        , viewFooter
        ]


viewHeader : H.Html msg
viewHeader =
    H.div []
        [ H.h2 [] [ H.text "Header" ]
        , Header.view (Header.Unauthenticated Nothing)
        , H.hr [] []
        , Header.view (Header.Unauthenticated <| Just Header.GuestHome)
        , H.hr [] []
        , Header.view (Header.Unauthenticated <| Just Header.Login)
        , H.hr [] []
        , Header.view (Header.Unauthenticated <| Just Header.Register)
        , H.hr [] []
        , Header.view (Header.Authenticated "Eric Simons" Nothing)
        , H.hr [] []
        , Header.view (Header.Authenticated "Eric Simons" <| Just Header.Home)
        , H.hr [] []
        , Header.view (Header.Authenticated "Eric Simons" <| Just Header.NewArticle)
        , H.hr [] []
        , Header.view (Header.Authenticated "Eric Simons" <| Just Header.Settings)
        , H.hr [] []
        , Header.view (Header.Authenticated "Eric Simons" <| Just Header.Profile)
        ]


viewHomePage : HomePageModel -> H.Html Msg
viewHomePage { tag, active, isFavourite, currentPage } =
    H.div []
        [ H.h2 [] [ H.text "Home" ]
        , H.div
            [ HA.class "home-page" ]
            [ Banner.view
            , H.div
                [ HA.class "container page" ]
                [ H.div
                    [ HA.class "row" ]
                    [ H.div
                        [ HA.class "col-md-9" ]
                        [ FeedToggle.view
                            { hasPersonal = True
                            , tag = tag
                            , active = active
                            , onClick = ClickedFeedToggle
                            }
                        , ArticlePreview.view
                            { author =
                                { username = "Eric Simons"
                                , imageSrc = "http://i.imgur.com/Qr71crq.jpg"
                                }
                            , date = "January 20th"
                            , favourites =
                                if isFavourite then
                                    30

                                else
                                    29
                            , isFavourite = isFavourite
                            , slug = "how-to-build-webapps-that-scale"
                            , title = "How to build webapps that scale"
                            , description = "This is the description for the post."
                            , tags =
                                [ "realworld"
                                , "implementations"
                                ]
                            , onClick = ClickedFavourite
                            }
                        , ArticlePreview.view
                            { author =
                                { username = "Albert Pai"
                                , imageSrc = "http://i.imgur.com/N4VcUeJ.jpg"
                                }
                            , date = "January 20th"
                            , favourites = 32
                            , isFavourite = False
                            , slug = "the-song-you-wont-ever-stop-singing"
                            , title = "The song you won't ever stop singing. No matter how hard you try."
                            , description = "This is the description for the post."
                            , tags =
                                [ "realworld"
                                , "implementations"
                                ]
                            , onClick = always NoOp
                            }
                        , Pagination.view
                            { pages = 5
                            , current = currentPage
                            , onClick = ClickedPagination
                            }
                        ]
                    , H.div
                        [ HA.class "col-md-3" ]
                        [ Sidebar.view <|
                            Sidebar.Tags
                                { tags =
                                    [ "programming"
                                    , "javascript"
                                    , "elm"
                                    , "emberjs"
                                    , "angularjs"
                                    , "react"
                                    , "node"
                                    , "django"
                                    , "rails"
                                    ]
                                , activeTag = tag
                                , onClick = ClickedSidebar
                                }
                        ]
                    ]
                ]
            ]
        ]


viewLoginPage : H.Html Msg
viewLoginPage =
    H.div []
        [ H.h2 [] [ H.text "Login" ]
        , H.div
            [ HA.class "auth-page" ]
            [ H.div
                [ HA.class "container page" ]
                [ H.div
                    [ HA.class "row" ]
                    [ Login.view
                        "col-md-6 offset-md-3 col-xs-12"
                        { loginForm =
                            { email = ""
                            , password = ""
                            , status = LoginForm.Invalid
                            , onInputEmail = always NoOp
                            , onInputPassword = always NoOp
                            , onSubmit = NoOp
                            }
                        , errorMessages =
                            [ "That email is already taken."
                            ]
                        }
                    ]
                ]
            ]
        ]


viewRegisterPage : H.Html Msg
viewRegisterPage =
    H.div []
        [ H.h2 [] [ H.text "Register" ]
        , H.div
            [ HA.class "auth-page" ]
            [ H.div
                [ HA.class "container page" ]
                [ H.div
                    [ HA.class "row" ]
                    [ Register.view
                        "col-md-6 offset-md-3 col-xs-12"
                        { registerForm =
                            { username = ""
                            , email = ""
                            , password = ""
                            , status = RegisterForm.Invalid
                            , onInputUsername = always NoOp
                            , onInputEmail = always NoOp
                            , onInputPassword = always NoOp
                            , onSubmit = NoOp
                            }
                        , errorMessages =
                            [ "That email is already taken."
                            ]
                        }
                    ]
                ]
            ]
        ]


viewSettingsPage : H.Html Msg
viewSettingsPage =
    H.div []
        [ H.h2 [] [ H.text "Settings" ]
        , H.div
            [ HA.class "settings-page" ]
            [ H.div
                [ HA.class "container page" ]
                [ H.div
                    [ HA.class "row" ]
                    [ Settings.view
                        "col-md-6 offset-md-3 col-xs-12"
                        { settingsForm =
                            { profilePicUrl = ""
                            , username = ""
                            , bio = ""
                            , email = ""
                            , newPassword = ""
                            , status = SettingsForm.Invalid
                            , onInputProfilePicUrl = always NoOp
                            , onInputUsername = always NoOp
                            , onInputBio = always NoOp
                            , onInputEmail = always NoOp
                            , onInputNewPassword = always NoOp
                            , onSubmit = NoOp
                            }
                        , errorMessages =
                            [ "That name is required."
                            ]
                        , onLogout = NoOp
                        }
                    ]
                ]
            ]
        ]


viewFooter : H.Html msg
viewFooter =
    Footer.view
