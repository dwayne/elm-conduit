module Main exposing (main)

import Browser
import Html as H
import Html.Attributes as HA
import View.ArticleContent as ArticleContent
import View.ArticleHeader as ArticleHeader
import View.ArticlePreview as ArticlePreview
import View.ArticlesToggle as ArticlesToggle
import View.Banner as Banner
import View.Editor as Editor
import View.EditorForm as EditorForm
import View.FeedToggle as FeedToggle
import View.FollowButton as FollowButton
import View.Footer as Footer
import View.Header as Header
import View.Login as Login
import View.LoginForm as LoginForm
import View.Pagination as Pagination
import View.ProfileHeader as ProfileHeader
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
    , editorPageModel : EditorPageModel
    , profilePageModel : ProfilePageModel
    }


type alias HomePageModel =
    { tag : String
    , activeTab : FeedToggle.Tab
    , isFavourite : Bool
    , currentPage : Int
    }


type alias EditorPageModel =
    { tag : String
    , tags : List String
    }


type alias ProfilePageModel =
    { activeTab : ArticlesToggle.Tab
    }


init : Model
init =
    { homePageModel =
        { tag = ""
        , activeTab = FeedToggle.Global
        , isFavourite = False
        , currentPage = 1
        }
    , editorPageModel =
        { tag = ""
        , tags =
            [ "elm"
            ]
        }
    , profilePageModel =
        { activeTab = ArticlesToggle.Personal
        }
    }



-- UPDATE


type Msg
    = NoOp
    | ClickedFeedToggle FeedToggle.Tab
    | ClickedFavourite Bool
    | ClickedPagination Int
    | ClickedSidebar String
    | InputTag String
    | EnterTag String
    | RemoveTag String
    | ClickedArticlesToggle ArticlesToggle.Tab


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model

        ClickedFeedToggle tab ->
            let
                homePageModel =
                    model.homePageModel

                newHomePageModel =
                    { homePageModel | activeTab = tab }
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
                        , activeTab = FeedToggle.Tag tag
                    }
            in
            { model | homePageModel = newHomePageModel }

        InputTag tag ->
            let
                editorPageModel =
                    model.editorPageModel

                newEditorPageModel =
                    { editorPageModel | tag = tag }
            in
            { model | editorPageModel = newEditorPageModel }

        EnterTag tag ->
            let
                cleanedTag =
                    String.trim tag

                editorPageModel =
                    model.editorPageModel

                newEditorPageModel =
                    if String.isEmpty cleanedTag then
                        editorPageModel

                    else
                        { editorPageModel
                            | tag = ""
                            , tags = editorPageModel.tags ++ [ cleanedTag ]
                        }
            in
            { model | editorPageModel = newEditorPageModel }

        RemoveTag tag ->
            let
                editorPageModel =
                    model.editorPageModel

                newEditorPageModel =
                    { editorPageModel
                        | tags =
                            List.filter
                                ((/=) tag)
                                editorPageModel.tags
                    }
            in
            { model | editorPageModel = newEditorPageModel }

        ClickedArticlesToggle tab ->
            let
                profilePageModel =
                    model.profilePageModel

                newProfilePageModel =
                    { profilePageModel | activeTab = tab }
            in
            { model | profilePageModel = newProfilePageModel }



-- VIEW


view : Model -> H.Html Msg
view { homePageModel, editorPageModel, profilePageModel } =
    H.div []
        [ viewHeader
        , viewHomePage homePageModel
        , viewLoginPage
        , viewRegisterPage
        , viewSettingsPage
        , viewEditorPage editorPageModel
        , viewProfilePage profilePageModel
        , viewArticle
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
viewHomePage { tag, activeTab, isFavourite, currentPage } =
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
                            , active = activeTab
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


viewEditorPage : EditorPageModel -> H.Html Msg
viewEditorPage { tag, tags } =
    H.div []
        [ H.h2 [] [ H.text "Editor" ]
        , H.div
            [ HA.class "editor-page" ]
            [ H.div
                [ HA.class "container page" ]
                [ H.div
                    [ HA.class "row" ]
                    [ Editor.view
                        "col-md-10 offset-md-1 col-xs-12"
                        { editorForm =
                            { title = ""
                            , description = ""
                            , body = ""
                            , tag = tag
                            , tags = tags
                            , status = EditorForm.Invalid
                            , onInputTitle = always NoOp
                            , onInputDescription = always NoOp
                            , onInputBody = always NoOp
                            , onInputTag = InputTag
                            , onEnterTag = EnterTag
                            , onRemoveTag = RemoveTag
                            , onSubmit = NoOp
                            }
                        , errorMessages =
                            [ "That title is required."
                            ]
                        }
                    ]
                ]
            ]
        ]


viewProfilePage : ProfilePageModel -> H.Html Msg
viewProfilePage { activeTab } =
    let
        name =
            "Eric Simons"

        imageUrl =
            "http://i.imgur.com/Qr71crq.jpg"

        bio =
            "Cofounder @GoThinkster, lived in Aol's HQ for a few months, kinda looks like Peeta from the Hunger Games"
    in
    H.div []
        [ H.h2 [] [ H.text "Profile" ]
        , H.div
            [ HA.class "profile-page" ]
            [ ProfileHeader.view
                { name = name
                , imageUrl = imageUrl
                , bio = bio
                , role =
                    ProfileHeader.Guest
                        { isFollowed = False
                        , isDisabled = False
                        , onFollow = NoOp
                        , onUnfollow = NoOp
                        }
                }
            , ProfileHeader.view
                { name = name
                , imageUrl = imageUrl
                , bio = bio
                , role =
                    ProfileHeader.Guest
                        { isFollowed = False
                        , isDisabled = True
                        , onFollow = NoOp
                        , onUnfollow = NoOp
                        }
                }
            , ProfileHeader.view
                { name = name
                , imageUrl = imageUrl
                , bio = bio
                , role =
                    ProfileHeader.Guest
                        { isFollowed = True
                        , isDisabled = False
                        , onFollow = NoOp
                        , onUnfollow = NoOp
                        }
                }
            , ProfileHeader.view
                { name = name
                , imageUrl = imageUrl
                , bio = bio
                , role =
                    ProfileHeader.Guest
                        { isFollowed = True
                        , isDisabled = True
                        , onFollow = NoOp
                        , onUnfollow = NoOp
                        }
                }
            , ProfileHeader.view
                { name = name
                , imageUrl = imageUrl
                , bio = bio
                , role = ProfileHeader.Owner
                }
            , H.div
                [ HA.class "container" ]
                [ H.div
                    [ HA.class "row" ]
                    [ H.div
                        [ HA.class "col-xs-12 col-md-10 offset-md-1" ]
                        [ ArticlesToggle.view
                            { active = activeTab
                            , onClick = ClickedArticlesToggle
                            }
                        , ArticlePreview.view
                            { author =
                                { username = "Eric Simons"
                                , imageSrc = "http://i.imgur.com/Qr71crq.jpg"
                                }
                            , date = "January 20th"
                            , favourites = 30
                            , isFavourite = True
                            , slug = "how-to-build-webapps-that-scale"
                            , title = "How to build webapps that scale"
                            , description = "This is the description for the post."
                            , tags =
                                [ "realworld"
                                , "implementations"
                                ]
                            , onClick = always NoOp
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
                            { pages = 2
                            , current = 1
                            , onClick = always NoOp
                            }
                        ]
                    ]
                ]
            ]
        ]


viewArticle : H.Html Msg
viewArticle =
    let
        title =
            "How to build webapps that scale"

        name =
            "Eric Simons"

        imageUrl =
            "http://i.imgur.com/Qr71crq.jpg"

        date =
            "January 20th"

        totalFollowers =
            10

        totalFavourites =
            29
    in
    H.div []
        [ H.h2 [] [ H.text "Article" ]
        , H.div
            [ HA.class "article-page" ]
            [ ArticleHeader.view
                { title = title
                , name = name
                , imageUrl = imageUrl
                , date = date
                , role =
                    ArticleHeader.Guest
                        { isDisabled = False
                        , isFollowed = False
                        , totalFollowers = totalFollowers
                        , onFollow = NoOp
                        , onUnfollow = NoOp
                        , isFavourite = True
                        , totalFavourites = totalFavourites
                        , onFavourite = NoOp
                        , onUnfavourite = NoOp
                        }
                }
            , ArticleHeader.view
                { title = title
                , name = name
                , imageUrl = imageUrl
                , date = date
                , role =
                    ArticleHeader.Guest
                        { isDisabled = False
                        , isFollowed = True
                        , totalFollowers = totalFollowers
                        , onFollow = NoOp
                        , onUnfollow = NoOp
                        , isFavourite = False
                        , totalFavourites = totalFavourites
                        , onFavourite = NoOp
                        , onUnfavourite = NoOp
                        }
                }
            , ArticleHeader.view
                { title = title
                , name = name
                , imageUrl = imageUrl
                , date = date
                , role =
                    ArticleHeader.Guest
                        { isDisabled = True
                        , isFollowed = False
                        , totalFollowers = totalFollowers
                        , onFollow = NoOp
                        , onUnfollow = NoOp
                        , isFavourite = False
                        , totalFavourites = totalFavourites
                        , onFavourite = NoOp
                        , onUnfavourite = NoOp
                        }
                }
            , ArticleHeader.view
                { title = title
                , name = name
                , imageUrl = imageUrl
                , date = date
                , role =
                    ArticleHeader.Owner
                        { isDisabled = False
                        , onDelete = NoOp
                        }
                }
            , ArticleHeader.view
                { title = title
                , name = name
                , imageUrl = imageUrl
                , date = date
                , role =
                    ArticleHeader.Owner
                        { isDisabled = True
                        , onDelete = NoOp
                        }
                }
            , H.div
                [ HA.class "container page" ]
                [ ArticleContent.view
                    { description = "Web development technologies have evolved at an incredible clip over the past few years."
                    , body = exampleArticleContentBody
                    , tags =
                        [ "realworld"
                        , "implementations"
                        ]
                    }
                ]
            , H.hr [] []
            ]
        ]


exampleArticleContentBody : String
exampleArticleContentBody =
    """
## Introducing RealWorld.

It's a great solution for learning how other frameworks work.
    """


viewFooter : H.Html msg
viewFooter =
    Footer.view
