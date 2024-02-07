module Main exposing (main)

import Browser
import Html as H
import Html.Attributes as HA
import Lib.OrderedSet as OrderedSet exposing (OrderedSet)
import View.ArticleContent as ArticleContent
import View.ArticleHeader as ArticleHeader
import View.ArticleMeta as ArticleMeta
import View.ArticlePreview as ArticlePreview
import View.ArticleTabs as ArticleTabs
import View.Comment as Comment
import View.CommentForm as CommentForm
import View.Editor as Editor
import View.EditorForm as EditorForm
import View.FeedTabs as FeedTabs
import View.FollowButton as FollowButton
import View.Footer as Footer
import View.HomeHeader as HomeHeader
import View.Login as Login
import View.LoginForm as LoginForm
import View.Navigation as Navigation
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
    , activeTab : FeedTabs.Tab
    , isFavourite : Bool
    , currentPage : Int
    }


type alias EditorPageModel =
    { tag : String
    , tags : OrderedSet String
    }


type alias ProfilePageModel =
    { activeTab : ArticleTabs.Tab
    }


init : Model
init =
    { homePageModel =
        { tag = ""
        , activeTab = FeedTabs.Global
        , isFavourite = False
        , currentPage = 1
        }
    , editorPageModel =
        { tag = ""
        , tags =
            OrderedSet.fromList
                [ "elm"
                , "javascript"
                , "python"
                , "haskell"
                ]
        }
    , profilePageModel =
        { activeTab = ArticleTabs.Personal
        }
    }



-- UPDATE


type Msg
    = NoOp
    | SwitchedFeedTabs FeedTabs.Tab
    | ToggledFavourite Bool
    | ClickedPagination Int
    | ClickedSidebar String
    | InputTag String
    | EnterTag String
    | RemoveTag String
    | SwitchedArticleTabs ArticleTabs.Tab


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model

        SwitchedFeedTabs tab ->
            let
                homePageModel =
                    model.homePageModel

                newHomePageModel =
                    { homePageModel | activeTab = tab }
            in
            { model | homePageModel = newHomePageModel }

        ToggledFavourite isFavourite ->
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
                        , activeTab = FeedTabs.Tag tag
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
                            , tags = OrderedSet.add cleanedTag editorPageModel.tags
                        }
            in
            { model | editorPageModel = newEditorPageModel }

        RemoveTag tag ->
            let
                editorPageModel =
                    model.editorPageModel

                newEditorPageModel =
                    { editorPageModel
                        | tags = OrderedSet.remove tag editorPageModel.tags
                    }
            in
            { model | editorPageModel = newEditorPageModel }

        SwitchedArticleTabs tab ->
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
        [ viewNavigation
        , viewHomePage homePageModel
        , viewLoginPage
        , viewRegisterPage
        , viewSettingsPage
        , viewEditorPage editorPageModel
        , viewProfilePage profilePageModel
        , viewArticle
        , viewFooter
        ]


viewNavigation : H.Html msg
viewNavigation =
    H.div []
        [ H.h2 [] [ H.text "Navigation" ]
        , Navigation.view (Navigation.Unauthenticated Nothing)
        , H.hr [] []
        , Navigation.view (Navigation.Unauthenticated <| Just Navigation.GuestHome)
        , H.hr [] []
        , Navigation.view (Navigation.Unauthenticated <| Just Navigation.Login)
        , H.hr [] []
        , Navigation.view (Navigation.Unauthenticated <| Just Navigation.Register)
        , H.hr [] []
        , Navigation.view (Navigation.Authenticated "Eric Simons" Nothing)
        , H.hr [] []
        , Navigation.view (Navigation.Authenticated "Eric Simons" <| Just Navigation.Home)
        , H.hr [] []
        , Navigation.view (Navigation.Authenticated "Eric Simons" <| Just Navigation.NewArticle)
        , H.hr [] []
        , Navigation.view (Navigation.Authenticated "Eric Simons" <| Just Navigation.Settings)
        , H.hr [] []
        , Navigation.view (Navigation.Authenticated "Eric Simons" <| Just Navigation.Profile)
        ]


viewHomePage : HomePageModel -> H.Html Msg
viewHomePage { tag, activeTab, isFavourite, currentPage } =
    H.div []
        [ H.h2 [] [ H.text "Home" ]
        , H.div
            [ HA.class "home-page" ]
            [ HomeHeader.view
            , H.div
                [ HA.class "container page" ]
                [ H.div
                    [ HA.class "row" ]
                    [ H.div
                        [ HA.class "col-md-9" ]
                        [ FeedTabs.view
                            { hasPersonal = True
                            , tag = tag
                            , activeTab = activeTab
                            , onSwitch = SwitchedFeedTabs
                            }
                        , ArticlePreview.view
                            { name = "Eric Simons"
                            , imageUrl = "http://i.imgur.com/Qr71crq.jpg"
                            , date = "January 20th"
                            , totalFavourites =
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
                            , onToggleFavourite = ToggledFavourite
                            }
                        , ArticlePreview.view
                            { name = "Albert Pai"
                            , imageUrl = "http://i.imgur.com/N4VcUeJ.jpg"
                            , date = "January 20th"
                            , totalFavourites = 32
                            , isFavourite = False
                            , slug = "the-song-you-wont-ever-stop-singing"
                            , title = "The song you won't ever stop singing. No matter how hard you try."
                            , description = "This is the description for the post."
                            , tags =
                                [ "realworld"
                                , "implementations"
                                ]
                            , onToggleFavourite = always NoOp
                            }
                        , Pagination.view
                            { totalPages = 5
                            , currentPage = currentPage
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
                        { form =
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
                        { form =
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
                        { form =
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
                        { form =
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
                        [ ArticleTabs.view
                            { activeTab = activeTab
                            , onSwitch = SwitchedArticleTabs
                            }
                        , ArticlePreview.view
                            { name = "Eric Simons"
                            , imageUrl = "http://i.imgur.com/Qr71crq.jpg"
                            , date = "January 20th"
                            , totalFavourites = 30
                            , isFavourite = True
                            , slug = "how-to-build-webapps-that-scale"
                            , title = "How to build webapps that scale"
                            , description = "This is the description for the post."
                            , tags =
                                [ "realworld"
                                , "implementations"
                                ]
                            , onToggleFavourite = always NoOp
                            }
                        , ArticlePreview.view
                            { name = "Albert Pai"
                            , imageUrl = "http://i.imgur.com/N4VcUeJ.jpg"
                            , date = "January 20th"
                            , totalFavourites = 32
                            , isFavourite = False
                            , slug = "the-song-you-wont-ever-stop-singing"
                            , title = "The song you won't ever stop singing. No matter how hard you try."
                            , description = "This is the description for the post."
                            , tags =
                                [ "realworld"
                                , "implementations"
                                ]
                            , onToggleFavourite = always NoOp
                            }
                        , Pagination.view
                            { totalPages = 2
                            , currentPage = 1
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
                , meta =
                    { name = name
                    , imageUrl = imageUrl
                    , date = date
                    , role =
                        ArticleMeta.Guest
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
                }
            , ArticleHeader.view
                { title = title
                , meta =
                    { name = name
                    , imageUrl = imageUrl
                    , date = date
                    , role =
                        ArticleMeta.Guest
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
                }
            , ArticleHeader.view
                { title = title
                , meta =
                    { name = name
                    , imageUrl = imageUrl
                    , date = date
                    , role =
                        ArticleMeta.Guest
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
                }
            , ArticleHeader.view
                { title = title
                , meta =
                    { name = name
                    , imageUrl = imageUrl
                    , date = date
                    , role =
                        ArticleMeta.Owner
                            { isDisabled = False
                            , onDelete = NoOp
                            }
                    }
                }
            , ArticleHeader.view
                { title = title
                , meta =
                    { name = name
                    , imageUrl = imageUrl
                    , date = date
                    , role =
                        ArticleMeta.Owner
                            { isDisabled = True
                            , onDelete = NoOp
                            }
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
                , H.hr [] []
                , H.div
                    [ HA.class "article-actions" ]
                    [ ArticleMeta.view
                        { name = name
                        , imageUrl = imageUrl
                        , date = date
                        , role =
                            ArticleMeta.Guest
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
                    ]
                , H.div
                    [ HA.class "row" ]
                    [ H.div
                        [ HA.class "col-xs-12 col-md-8 offset-md-2" ]
                        [ CommentForm.view
                            { comment = ""
                            , imageUrl = imageUrl
                            , status = CommentForm.Invalid
                            , onInputComment = always NoOp
                            , onSubmit = NoOp
                            }
                        , CommentForm.view
                            { comment = "This is a comment."
                            , imageUrl = imageUrl
                            , status = CommentForm.Valid
                            , onInputComment = always NoOp
                            , onSubmit = NoOp
                            }
                        , CommentForm.view
                            { comment = ""
                            , imageUrl = imageUrl
                            , status = CommentForm.Loading
                            , onInputComment = always NoOp
                            , onSubmit = NoOp
                            }
                        , Comment.view
                            { comment = "With supporting text below as a natural lead-in to additional content."
                            , name = "Jacob Schmidt"
                            , imageUrl = imageUrl
                            , date = "Dec 29th"
                            , maybeDelete = Nothing
                            }
                        , Comment.view
                            { comment = "With supporting text below as a natural lead-in to additional content."
                            , name = "Jacob Schmidt"
                            , imageUrl = imageUrl
                            , date = "Dec 29th"
                            , maybeDelete =
                                Just
                                    { isDisabled = False
                                    , onDelete = NoOp
                                    }
                            }
                        , Comment.view
                            { comment = "With supporting text below as a natural lead-in to additional content."
                            , name = "Jacob Schmidt"
                            , imageUrl = imageUrl
                            , date = "Dec 29th"
                            , maybeDelete =
                                Just
                                    { isDisabled = True
                                    , onDelete = NoOp
                                    }
                            }
                        ]
                    ]
                ]
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
