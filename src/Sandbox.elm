module Sandbox exposing (main)

import Browser
import Data.PageNumber as PageNumber exposing (PageNumber)
import Data.Slug as Slug exposing (Slug)
import Data.Tag as Tag exposing (Tag)
import Data.Timestamp as Timestamp exposing (Timestamp)
import Data.Total as Total
import Data.Username as Username exposing (Username)
import Html as H
import Html.Attributes as HA
import Lib.NonEmptyString as NonEmptyString
import Lib.OrderedSet as OrderedSet exposing (OrderedSet)
import Time
import Url exposing (Url)
import View.ArticleActionsForGuest as ArticleActionsForGuest
import View.ArticleContent as ArticleContent
import View.ArticleHeader as ArticleHeader
import View.ArticleMeta as ArticleMeta
import View.ArticlePreview as ArticlePreview
import View.ArticleTabs as ArticleTabs
import View.Column as Column
import View.Comment as Comment
import View.CommentForm as CommentForm
import View.Editor as Editor
import View.FeedTabs as FeedTabs
import View.Footer as Footer
import View.HomeHeader as HomeHeader
import View.Layout as Layout
import View.Login as Login
import View.Navigation as Navigation
import View.Pagination as Pagination
import View.ProfileHeader as ProfileHeader
import View.Register as Register
import View.Settings as Settings
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
    { maybeTag : Maybe Tag
    , activeTab : FeedTabs.Tab
    , isFavourite : Bool
    , currentPageNumber : PageNumber
    }


type alias EditorPageModel =
    { tag : String
    , tags : OrderedSet Tag
    }


type alias ProfilePageModel =
    { activeTab : ArticleTabs.Tab
    }


init : Model
init =
    { homePageModel =
        { maybeTag = Nothing
        , activeTab = FeedTabs.Global
        , isFavourite = False
        , currentPageNumber = PageNumber.one
        }
    , editorPageModel =
        { tag = ""
        , tags =
            [ "elm"
            , "javascript"
            , "python"
            , "haskell"
            ]
                |> tagsFromStrings
                |> OrderedSet.fromList
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
    | ChangedPageNumber PageNumber
    | ClickedTag Tag
    | ChangedTag String
    | EnteredTag Tag
    | RemovedTag Tag
    | SwitchedArticleTabs ArticleTabs.Tab


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model

        SwitchedFeedTabs tab ->
            updateHomePageModel
                (\m -> { m | activeTab = tab })
                model

        ToggledFavourite isFavourite ->
            updateHomePageModel
                (\m -> { m | isFavourite = isFavourite })
                model

        ChangedPageNumber newPageNumber ->
            updateHomePageModel
                (\m -> { m | currentPageNumber = newPageNumber })
                model

        ClickedTag tag ->
            updateHomePageModel
                (\m ->
                    if Tag.toString tag == "clear" then
                        { m | maybeTag = Nothing, activeTab = FeedTabs.Global }

                    else
                        { m | maybeTag = Just tag, activeTab = FeedTabs.Tag tag }
                )
                model

        ChangedTag tag ->
            updateEditorPageModel
                (\m -> { m | tag = tag })
                model

        EnteredTag tag ->
            updateEditorPageModel
                (\m -> { m | tag = "", tags = OrderedSet.add tag m.tags })
                model

        RemovedTag tag ->
            updateEditorPageModel
                (\m -> { m | tags = OrderedSet.remove tag m.tags })
                model

        SwitchedArticleTabs tab ->
            updateProfilePageModel
                (\m -> { m | activeTab = tab })
                model


updateHomePageModel : (HomePageModel -> HomePageModel) -> Model -> Model
updateHomePageModel transform model =
    { model | homePageModel = transform model.homePageModel }


updateEditorPageModel : (EditorPageModel -> EditorPageModel) -> Model -> Model
updateEditorPageModel transform model =
    { model | editorPageModel = transform model.editorPageModel }


updateProfilePageModel : (ProfilePageModel -> ProfilePageModel) -> Model -> Model
updateProfilePageModel transform model =
    { model | profilePageModel = transform model.profilePageModel }



-- CONSTANTS


type alias User =
    { username : Username
    , imageUrl : Url
    }


maybeEricSimons : Maybe User
maybeEricSimons =
    Maybe.map2 User
        (Username.fromString "Eric Simons")
        (Url.fromString "http://i.imgur.com/Qr71crq.jpg")


maybeAlbertPai : Maybe User
maybeAlbertPai =
    Maybe.map2 User
        (Username.fromString "Albert Pai")
        (Url.fromString "http://i.imgur.com/N4VcUeJ.jpg")


maybeSmileyCyrus : Maybe User
maybeSmileyCyrus =
    Maybe.map2 User
        (Username.fromString "Smiley Cyrus")
        (buildUrl "/images/smiley-cyrus.jpeg")


type alias Article =
    { slug : Slug
    , title : String
    , description : String
    , body : String
    , tags : List Tag
    , createdAt : Timestamp
    }


maybeScaleWebAppsArticle : Maybe Article
maybeScaleWebAppsArticle =
    Maybe.map2
        (\slug createdAt ->
            { slug = slug
            , title = "How to build webapps that scale"
            , description = "You will learn how to build webapps that scale."
            , body =
                """
## Introduction

In this article I'm going to **teach** you *how to build webapps that scale*.
                """
            , tags =
                tagsFromStrings
                    [ "implementations"
                    , "realword"
                    , "scale"
                    , "webapps"
                    ]
            , createdAt = createdAt
            }
        )
        (Slug.fromString "how-to-build-webapps-that-scale")
        (Timestamp.fromString "2024-01-01T00:00:00.000Z")


maybeNeverStopSingingSongArticle : Maybe Article
maybeNeverStopSingingSongArticle =
    Maybe.map2
        (\slug createdAt ->
            { slug = slug
            , title = "The song you won't ever stop singing"
            , description = "The song you won't ever stop singing. No matter how hard you try."
            , body = ""
            , tags =
                tagsFromStrings
                    [ "song"
                    , "singing"
                    ]
            , createdAt = createdAt
            }
        )
        (Slug.fromString "the-song-you-wont-ever-stop-singing")
        (Timestamp.fromString "2024-01-02T00:00:00.000Z")


zone : Time.Zone
zone =
    Time.utc



-- VIEW


view : Model -> H.Html Msg
view { homePageModel, editorPageModel, profilePageModel } =
    let
        titlesAndIds =
            [ ( "Navigation", "navigation" )
            , ( "Home Page", "home-page" )
            , ( "Login Page", "login-page" )
            , ( "Register Page", "register-page" )
            , ( "Settings Page", "settings-page" )
            , ( "Editor Page", "editor-page" )
            , ( "Article Page", "article-page" )
            , ( "Profile Page", "profile-page" )
            , ( "Footer", "footer" )
            ]

        contents =
            [ viewNavigation
            , viewHomePage homePageModel
            , viewLoginPage
            , viewRegisterPage
            , viewSettingsPage
            , viewEditorPage editorPageModel
            , viewArticlePage
            , viewProfilePage profilePageModel
            , viewFooter
            ]

        showcases =
            contents
                |> zip titlesAndIds
                |> List.map
                    (\( ( title, id ), content ) ->
                        viewShowcase title id content
                    )
                |> H.div []
    in
    H.div []
        [ H.h1 [] [ H.text "Conduit Sandbox" ]
        , viewTableOfContents titlesAndIds
        , showcases
        ]


viewNavigation : H.Html Msg
viewNavigation =
    viewMaybe
        (\{ username, imageUrl } ->
            let
                userDetails =
                    { username = username
                    , imageUrl = imageUrl
                    , onLogout = NoOp
                    }
            in
            H.div []
                [ Navigation.view { role = Navigation.guest }
                , Navigation.view { role = Navigation.guestHome }
                , Navigation.view { role = Navigation.login }
                , Navigation.view { role = Navigation.register }
                , Navigation.view { role = Navigation.user userDetails }
                , Navigation.view { role = Navigation.userHome userDetails }
                , Navigation.view { role = Navigation.newArticle userDetails }
                , Navigation.view { role = Navigation.settings userDetails }
                , Navigation.view { role = Navigation.profile userDetails }
                ]
        )
        maybeEricSimons


viewHomePage : HomePageModel -> H.Html Msg
viewHomePage { maybeTag, activeTab, isFavourite, currentPageNumber } =
    Layout.view
        { name = "home"
        , role = Navigation.guestHome
        , maybeHeader = Just HomeHeader.view
        }
        [ Column.viewDouble
            { left =
                [ FeedTabs.view
                    { hasPersonal = True
                    , maybeTag = maybeTag
                    , activeTab = activeTab
                    , isDisabled = False
                    , onSwitch = SwitchedFeedTabs
                    }
                , viewMaybe2
                    (\{ username, imageUrl } { slug, title, description, tags, createdAt } ->
                        ArticlePreview.view
                            { role = ArticlePreview.Guest
                            , username = username
                            , imageUrl = imageUrl
                            , zone = zone
                            , createdAt = createdAt
                            , slug = slug
                            , title = title
                            , description = description
                            , tags = tags
                            }
                    )
                    maybeEricSimons
                    maybeScaleWebAppsArticle
                , viewMaybe2
                    (\{ username, imageUrl } { slug, title, description, tags, createdAt } ->
                        ArticlePreview.view
                            { role =
                                ArticlePreview.User
                                    { isLoading = False
                                    , totalFavourites =
                                        if isFavourite then
                                            Total.fromInt 30

                                        else
                                            Total.fromInt 29
                                    , isFavourite = isFavourite
                                    , onToggleFavourite = ToggledFavourite
                                    }
                            , username = username
                            , imageUrl = imageUrl
                            , zone = zone
                            , createdAt = createdAt
                            , slug = slug
                            , title = title
                            , description = description
                            , tags = tags
                            }
                    )
                    maybeAlbertPai
                    maybeNeverStopSingingSongArticle
                , Pagination.view
                    { totalPages = Total.fromInt 5
                    , currentPageNumber = currentPageNumber
                    , onChangePageNumber = ChangedPageNumber
                    }
                ]
            , right =
                [ Sidebar.view Sidebar.Loading
                , H.hr [] []
                , Sidebar.view <|
                    Sidebar.Tags
                        { tags =
                            tagsFromStrings
                                [ "programming"
                                , "javascript"
                                , "elm"
                                , "emberjs"
                                , "angularjs"
                                , "react"
                                , "node"
                                , "django"
                                , "rails"
                                , "clear"
                                ]
                        , activeTag = maybeTag
                        , onClick = ClickedTag
                        }
                , H.hr [] []
                , Sidebar.view <|
                    Sidebar.Error "Unable to load tags."
                ]
            }
        ]


viewLoginPage : H.Html Msg
viewLoginPage =
    Layout.view
        { name = "auth"
        , role = Navigation.login
        , maybeHeader = Nothing
        }
        [ Column.viewSingle Column.ExtraSmall
            [ Login.view
                { form =
                    { email = ""
                    , password = ""
                    , isDisabled = False
                    , onInputEmail = always NoOp
                    , onInputPassword = always NoOp
                    , onSubmit = NoOp
                    }
                , errorMessages =
                    [ "email can't be blank"
                    ]
                }
            ]
        ]


viewRegisterPage : H.Html Msg
viewRegisterPage =
    Layout.view
        { name = "auth"
        , role = Navigation.register
        , maybeHeader = Nothing
        }
        [ Column.viewSingle Column.ExtraSmall
            [ Register.view
                { form =
                    { username = ""
                    , email = ""
                    , password = ""
                    , isDisabled = False
                    , onInputUsername = always NoOp
                    , onInputEmail = always NoOp
                    , onInputPassword = always NoOp
                    , onSubmit = NoOp
                    }
                , errorMessages =
                    [ "username has already been taken"
                    , "email has already been taken"
                    ]
                }
            ]
        ]


viewSettingsPage : H.Html Msg
viewSettingsPage =
    viewMaybe
        (\{ username, imageUrl } ->
            Layout.view
                { name = "settings"
                , role =
                    Navigation.settings
                        { username = username
                        , imageUrl = imageUrl
                        , onLogout = NoOp
                        }
                , maybeHeader = Nothing
                }
                [ Column.viewSingle Column.ExtraSmall
                    [ Settings.view
                        { form =
                            { imageUrl = Url.toString imageUrl
                            , username = Username.toString username
                            , bio = ""
                            , email = "eric.simons@realworld.com"
                            , password = ""
                            , isDisabled = False
                            , onInputImageUrl = always NoOp
                            , onInputUsername = always NoOp
                            , onInputBio = always NoOp
                            , onInputEmail = always NoOp
                            , onInputPassword = always NoOp
                            , onSubmit = NoOp
                            }
                        , errorMessages = []
                        , onLogout = NoOp
                        }
                    ]
                ]
        )
        maybeEricSimons


viewEditorPage : EditorPageModel -> H.Html Msg
viewEditorPage { tag, tags } =
    viewMaybe
        (\{ username, imageUrl } ->
            Layout.view
                { name = "editor"
                , role =
                    Navigation.newArticle
                        { username = username
                        , imageUrl = imageUrl
                        , onLogout = NoOp
                        }
                , maybeHeader = Nothing
                }
                [ Column.viewSingle Column.Medium
                    [ Editor.view
                        { form =
                            { title = ""
                            , description = ""
                            , body = ""
                            , tag = tag
                            , tags = tags
                            , isDisabled = False
                            , onInputTitle = always NoOp
                            , onInputDescription = always NoOp
                            , onInputBody = always NoOp
                            , onInputTag = ChangedTag
                            , onEnterTag = EnteredTag
                            , onRemoveTag = RemovedTag
                            , onSubmit = NoOp
                            }
                        , errorMessages = []
                        }
                    ]
                ]
        )
        maybeEricSimons


viewArticlePage : H.Html Msg
viewArticlePage =
    let
        maybeArticleData =
            Maybe.map2
                (\{ username, imageUrl } { slug, title, createdAt } ->
                    ArticleData
                        username
                        imageUrl
                        slug
                        title
                        createdAt
                )
                maybeEricSimons
                maybeScaleWebAppsArticle

        totalFavourites =
            Total.fromInt 29
    in
    H.div
        [ HA.class "article-page" ]
        [ viewMaybe
            (\{ username, imageUrl, title, createdAt } ->
                ArticleHeader.view
                    { title = title
                    , meta =
                        { username = username
                        , imageUrl = imageUrl
                        , zone = zone
                        , createdAt = createdAt
                        , role = ArticleMeta.Guest
                        }
                    }
            )
            maybeArticleData
        , viewMaybe
            (\{ username, imageUrl, title, createdAt } ->
                ArticleHeader.view
                    { title = title
                    , meta =
                        { username = username
                        , imageUrl = imageUrl
                        , zone = zone
                        , createdAt = createdAt
                        , role =
                            ArticleMeta.User
                                { isDisabled = False
                                , isFollowing = False
                                , onFollow = NoOp
                                , onUnfollow = NoOp
                                , isFavourite = False
                                , totalFavourites = totalFavourites
                                , onFavourite = NoOp
                                , onUnfavourite = NoOp
                                }
                        }
                    }
            )
            maybeArticleData
        , viewMaybe
            (\{ username, imageUrl, title, createdAt } ->
                ArticleHeader.view
                    { title = title
                    , meta =
                        { username = username
                        , imageUrl = imageUrl
                        , zone = zone
                        , createdAt = createdAt
                        , role =
                            ArticleMeta.User
                                { isDisabled = False
                                , isFollowing = True
                                , onFollow = NoOp
                                , onUnfollow = NoOp
                                , isFavourite = False
                                , totalFavourites = totalFavourites
                                , onFavourite = NoOp
                                , onUnfavourite = NoOp
                                }
                        }
                    }
            )
            maybeArticleData
        , viewMaybe
            (\{ username, imageUrl, slug, title, createdAt } ->
                ArticleHeader.view
                    { title = title
                    , meta =
                        { username = username
                        , imageUrl = imageUrl
                        , zone = zone
                        , createdAt = createdAt
                        , role =
                            ArticleMeta.Author
                                { isDisabled = False
                                , slug = slug
                                , onDelete = always NoOp
                                }
                        }
                    }
            )
            maybeArticleData
        , viewMaybe
            (\{ username, imageUrl, slug, title, createdAt } ->
                ArticleHeader.view
                    { title = title
                    , meta =
                        { username = username
                        , imageUrl = imageUrl
                        , zone = zone
                        , createdAt = createdAt
                        , role =
                            ArticleMeta.Author
                                { isDisabled = True
                                , slug = slug
                                , onDelete = always NoOp
                                }
                        }
                    }
            )
            maybeArticleData
        , H.div
            [ HA.class "container page" ]
            [ viewMaybe
                (\{ description, body, tags } ->
                    Column.viewSingle Column.Large
                        [ ArticleContent.view
                            { description = description
                            , body = body
                            , tags = tags
                            }
                        ]
                )
                maybeScaleWebAppsArticle
            , H.hr [] []
            , ArticleActionsForGuest.view
            , H.div
                [ HA.class "article-actions" ]
                [ viewMaybe
                    (\{ username, imageUrl, createdAt } ->
                        ArticleMeta.view
                            { username = username
                            , imageUrl = imageUrl
                            , zone = zone
                            , createdAt = createdAt
                            , role =
                                ArticleMeta.User
                                    { isDisabled = False
                                    , isFollowing = False
                                    , onFollow = NoOp
                                    , onUnfollow = NoOp
                                    , isFavourite = True
                                    , totalFavourites = totalFavourites
                                    , onFavourite = NoOp
                                    , onUnfavourite = NoOp
                                    }
                            }
                    )
                    maybeArticleData
                ]
            , Column.viewSingle Column.Small
                [ viewMaybe
                    (\{ imageUrl } ->
                        CommentForm.view
                            { htmlId = "comment-form-1"
                            , comment = ""
                            , imageUrl = imageUrl
                            , isDisabled = False
                            , onInputComment = always NoOp
                            , onSubmit = NoOp
                            }
                    )
                    maybeEricSimons
                , viewMaybe
                    (\{ imageUrl } ->
                        CommentForm.view
                            { htmlId = "comment-form-2"
                            , comment = "This is a new comment."
                            , imageUrl = imageUrl
                            , isDisabled = False
                            , onInputComment = always NoOp
                            , onSubmit = NoOp
                            }
                    )
                    maybeEricSimons
                , viewMaybe3
                    (\body { username, imageUrl } createdAt ->
                        Comment.view
                            { body = body
                            , username = username
                            , imageUrl = imageUrl
                            , zone = zone
                            , createdAt = createdAt
                            , maybeDelete = Nothing
                            }
                    )
                    (NonEmptyString.fromString "This is the fourth comment.")
                    maybeSmileyCyrus
                    (Timestamp.fromString "2023-12-17T19:31:59.987Z")
                , viewMaybe3
                    (\body { username, imageUrl } createdAt ->
                        Comment.view
                            { body = body
                            , username = username
                            , imageUrl = imageUrl
                            , zone = zone
                            , createdAt = createdAt
                            , maybeDelete = Nothing
                            }
                    )
                    (NonEmptyString.fromString "This is the third comment.")
                    maybeAlbertPai
                    (Timestamp.fromString "2023-12-01T01:25:37.123Z")
                , viewMaybe3
                    (\body { username, imageUrl } createdAt ->
                        Comment.view
                            { body = body
                            , username = username
                            , imageUrl = imageUrl
                            , zone = zone
                            , createdAt = createdAt
                            , maybeDelete =
                                Just
                                    { isDisabled = False
                                    , onDelete = NoOp
                                    }
                            }
                    )
                    (NonEmptyString.fromString "This is the second comment.")
                    maybeEricSimons
                    (Timestamp.fromString "2023-11-05T08:40:12.451Z")
                , viewMaybe3
                    (\body { username, imageUrl } createdAt ->
                        Comment.view
                            { body = body
                            , username = username
                            , imageUrl = imageUrl
                            , zone = zone
                            , createdAt = createdAt
                            , maybeDelete =
                                Just
                                    { isDisabled = True
                                    , onDelete = NoOp
                                    }
                            }
                    )
                    (NonEmptyString.fromString "This is the first comment.")
                    maybeEricSimons
                    (Timestamp.fromString "2023-10-23T15:26:09.619Z")
                ]
            ]
        ]


type alias ArticleData =
    { username : Username
    , imageUrl : Url
    , slug : Slug
    , title : String
    , createdAt : Timestamp
    }


viewProfilePage : ProfilePageModel -> H.Html Msg
viewProfilePage { activeTab } =
    H.div
        [ HA.class "profile-page" ]
        [ viewProfileHeader ProfileHeader.Guest
        , H.hr [] []
        , viewProfileHeaderUser False
        , H.hr [] []
        , viewProfileHeaderUser True
        , H.hr [] []
        , viewProfileHeader ProfileHeader.Owner
        , H.div
            [ HA.class "container page" ]
            [ Column.viewSingle Column.Medium
                [ ArticleTabs.view
                    { activeTab = activeTab
                    , isDisabled = False
                    , onSwitch = SwitchedArticleTabs
                    }
                , viewMaybe2
                    (\{ username, imageUrl } { slug, title, description, tags, createdAt } ->
                        ArticlePreview.view
                            { role = ArticlePreview.Guest
                            , username = username
                            , imageUrl = imageUrl
                            , zone = zone
                            , createdAt = createdAt
                            , slug = slug
                            , title = title
                            , description = description
                            , tags = tags
                            }
                    )
                    maybeEricSimons
                    maybeScaleWebAppsArticle
                , viewMaybe2
                    (\{ username, imageUrl } { slug, title, description, tags, createdAt } ->
                        ArticlePreview.view
                            { role =
                                ArticlePreview.User
                                    { isLoading = False
                                    , totalFavourites = Total.fromInt 30
                                    , isFavourite = True
                                    , onToggleFavourite = always NoOp
                                    }
                            , username = username
                            , imageUrl = imageUrl
                            , zone = zone
                            , createdAt = createdAt
                            , slug = slug
                            , title = title
                            , description = description
                            , tags = tags
                            }
                    )
                    maybeAlbertPai
                    maybeNeverStopSingingSongArticle
                , Pagination.view
                    { totalPages = Total.fromInt 2
                    , currentPageNumber = PageNumber.fromInt 1
                    , onChangePageNumber = always NoOp
                    }
                ]
            ]
        ]


viewProfileHeaderUser : Bool -> H.Html Msg
viewProfileHeaderUser isFollowing =
    viewProfileHeader <|
        ProfileHeader.User
            { isFollowing = isFollowing
            , isDisabled = False
            , onFollow = NoOp
            , onUnfollow = NoOp
            }


viewProfileHeader : ProfileHeader.Role msg -> H.Html msg
viewProfileHeader role =
    viewMaybe
        (\{ username, imageUrl } ->
            ProfileHeader.view
                { username = username
                , imageUrl = imageUrl
                , bio = "This is my short bio."
                , role = role
                }
        )
        maybeEricSimons


viewFooter : H.Html msg
viewFooter =
    Footer.view


viewTableOfContents : List ( String, String ) -> H.Html msg
viewTableOfContents =
    H.ul []
        << List.map
            (\( title, id ) ->
                H.li [] [ H.a [ HA.href <| "#" ++ id ] [ H.text title ] ]
            )


viewShowcase : String -> String -> H.Html msg -> H.Html msg
viewShowcase title id content =
    H.div []
        [ H.h2 [ HA.id id ] [ H.text title ]
        , content
        ]


viewMaybe : (a -> H.Html msg) -> Maybe a -> H.Html msg
viewMaybe toHtml =
    Maybe.map toHtml >> Maybe.withDefault viewEmpty


viewMaybe2 : (a -> b -> H.Html msg) -> Maybe a -> Maybe b -> H.Html msg
viewMaybe2 toHtml maybeA =
    Maybe.map2 toHtml maybeA >> Maybe.withDefault viewEmpty


viewMaybe3 : (a -> b -> c -> H.Html msg) -> Maybe a -> Maybe b -> Maybe c -> H.Html msg
viewMaybe3 toHtml maybeA maybeB =
    Maybe.map3 toHtml maybeA maybeB >> Maybe.withDefault viewEmpty


viewEmpty : H.Html msg
viewEmpty =
    H.text ""



-- HELPERS


buildUrl : String -> Maybe Url
buildUrl path =
    Url.fromString <| baseUrl ++ path


baseUrl : String
baseUrl =
    "http://localhost:9001"


tagsFromStrings : List String -> List Tag
tagsFromStrings =
    List.filterMap Tag.fromString


zip : List a -> List b -> List ( a, b )
zip alist blist =
    case ( alist, blist ) of
        ( [], [] ) ->
            []

        ( a :: restAList, b :: restBList ) ->
            ( a, b ) :: zip restAList restBList

        _ ->
            []
