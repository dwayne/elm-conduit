module Page.Profile exposing (InitOptions, Model, Msg, UpdateOptions, ViewOptions, init, update, view)

import Api
import Api.GetArticles as GetArticles
import Api.GetProfile as GetProfile
import Api.ToggleFavourite as ToggleFavourite
import Api.ToggleFollow as ToggleFollow
import Data.Article as Article exposing (Article)
import Data.PageNumber as PageNumber exposing (PageNumber)
import Data.Pager as Pager exposing (Pager)
import Data.Route as Route exposing (Route)
import Data.Slug exposing (Slug)
import Data.Token exposing (Token)
import Data.User exposing (User)
import Data.Username exposing (Username)
import Data.Viewer as Viewer exposing (Viewer)
import Html as H
import Html.Attributes as HA
import Lib.RemoteData as RemoteData exposing (RemoteData)
import Lib.Task as Task
import Time
import Url exposing (Url)
import View.ArticlePreview as ArticlePreview
import View.ArticleTabs as ArticleTabs
import View.Column as Column
import View.Layout as Layout
import View.Navigation as Navigation
import View.Pagination as Pagination
import View.ProfileHeader as ProfileHeader



-- MODEL


type alias Model =
    { username : Username
    , remoteDataProfile : RemoteData () GetProfile.Profile
    , activeTab : ArticleTabs.Tab
    , remoteDataArticles : RemoteData () (List Article)
    , togglingFavourite : Maybe Slug
    , currentPageNumber : PageNumber
    , pager : Pager
    , isDisabled : Bool
    }


type alias InitOptions msg =
    { apiUrl : Url
    , maybeToken : Maybe Token
    , username : Username
    , showFavourites : Bool
    , onChange : Msg -> msg
    }


init : InitOptions msg -> ( Model, Cmd msg )
init { apiUrl, maybeToken, username, showFavourites, onChange } =
    let
        activeTab =
            if showFavourites then
                ArticleTabs.Favourites

            else
                ArticleTabs.Personal

        currentPageNumber =
            PageNumber.one

        pager =
            Pager.five
    in
    ( { username = username
      , remoteDataProfile = RemoteData.Loading
      , activeTab = activeTab
      , remoteDataArticles = RemoteData.Loading
      , togglingFavourite = Nothing
      , currentPageNumber = currentPageNumber
      , pager = pager
      , isDisabled = False
      }
    , [ GetProfile.getProfile
            apiUrl
            { maybeToken = maybeToken
            , username = username
            , onResponse = GotGetProfileResponse
            }
      , getArticles
            { apiUrl = apiUrl
            , maybeToken = maybeToken
            , username = username
            , activeTab = activeTab
            , currentPageNumber = currentPageNumber
            , pager = pager
            }
      ]
        |> Cmd.batch
        |> Cmd.map onChange
    )



-- UPDATE


type Msg
    = GotGetProfileResponse (Result (Api.Error ()) GetProfile.Profile)
    | ToggledFollow Token Username Bool
    | GotToggleFollowResponse (Result (Api.Error ()) Bool)
    | GotGetArticlesResponse (Result (Api.Error ()) GetArticles.Articles)
    | SwitchedArticleTabs ArticleTabs.Tab
    | ToggledFavourite Token Slug Bool
    | GotToggleFavouriteResponse (Result (Api.Error ()) ToggleFavourite.TotalFavourites)
    | ChangedPageNumber PageNumber


type alias UpdateOptions msg =
    { apiUrl : Url
    , viewer : Viewer
    , onChangeRoute : Route -> msg
    , onChange : Msg -> msg
    }


update : UpdateOptions msg -> Msg -> Model -> ( Model, Cmd msg )
update options msg model =
    case msg of
        GotGetProfileResponse result ->
            ( result
                |> Result.map
                    (\profile ->
                        { model | remoteDataProfile = RemoteData.Success profile }
                    )
                |> Result.withDefault { model | remoteDataProfile = RemoteData.Failure () }
            , Cmd.none
            )

        ToggledFollow token username isFollowing ->
            ( { model | isDisabled = True }
            , ToggleFollow.toggleFollow
                options.apiUrl
                { token = token
                , username = username
                , isFollowing = isFollowing
                , onResponse = GotToggleFollowResponse
                }
                |> Cmd.map options.onChange
            )

        GotToggleFollowResponse result ->
            let
                newModel =
                    { model | isDisabled = False }
            in
            ( result
                |> Result.map
                    (\isFollowing ->
                        { newModel
                            | remoteDataProfile =
                                RemoteData.map
                                    (\profile -> { profile | isFollowing = isFollowing })
                                    newModel.remoteDataProfile
                        }
                    )
                |> Result.withDefault newModel
            , Cmd.none
            )

        GotGetArticlesResponse result ->
            ( result
                |> Result.map
                    (\{ articles, totalArticles } ->
                        { model
                            | remoteDataArticles = RemoteData.Success articles
                            , pager = Pager.setTotalPages totalArticles model.pager
                        }
                    )
                |> Result.withDefault { model | remoteDataArticles = RemoteData.Failure () }
            , Cmd.none
            )

        SwitchedArticleTabs tab ->
            ( { model
                | activeTab = tab
                , remoteDataArticles = RemoteData.Loading
              }
            , Cmd.batch
                [ let
                    route =
                        case tab of
                            ArticleTabs.Personal ->
                                Route.Profile model.username

                            ArticleTabs.Favourites ->
                                Route.Favourites model.username
                  in
                  Task.dispatch <| options.onChangeRoute route
                , getArticles
                    { apiUrl = options.apiUrl
                    , maybeToken = Viewer.toToken options.viewer
                    , username = model.username
                    , activeTab = tab
                    , currentPageNumber = PageNumber.one
                    , pager = model.pager
                    }
                    |> Cmd.map options.onChange
                ]
            )

        ToggledFavourite token slug isFavourite ->
            ( { model | togglingFavourite = Just slug }
            , ToggleFavourite.toggleFavourite
                options.apiUrl
                { token = token
                , slug = slug
                , isFavourite = isFavourite
                , onResponse = GotToggleFavouriteResponse
                }
                |> Cmd.map options.onChange
            )

        GotToggleFavouriteResponse result ->
            let
                newModel =
                    { model | togglingFavourite = Nothing }
            in
            case result of
                Ok totalFavourites ->
                    ( { newModel | remoteDataArticles = updateFavourite totalFavourites model.remoteDataArticles }
                    , Cmd.none
                    )

                Err _ ->
                    ( newModel
                    , Cmd.none
                    )

        ChangedPageNumber pageNumber ->
            ( { model
                | remoteDataArticles = RemoteData.Loading
                , currentPageNumber = pageNumber
              }
            , getArticles
                { apiUrl = options.apiUrl
                , maybeToken = Viewer.toToken options.viewer
                , username = model.username
                , activeTab = model.activeTab
                , currentPageNumber = pageNumber
                , pager = model.pager
                }
                |> Cmd.map options.onChange
            )


updateFavourite : ToggleFavourite.TotalFavourites -> RemoteData () (List Article) -> RemoteData () (List Article)
updateFavourite { slug, isFavourite, totalFavourites } =
    RemoteData.map
        (List.map
            (\article ->
                if article.slug == slug then
                    { article | isFavourite = isFavourite, totalFavourites = totalFavourites }

                else
                    article
            )
        )



-- HTTP


getArticles :
    { apiUrl : Url
    , maybeToken : Maybe Token
    , username : Username
    , activeTab : ArticleTabs.Tab
    , currentPageNumber : PageNumber
    , pager : Pager
    }
    -> Cmd Msg
getArticles { apiUrl, maybeToken, username, activeTab, currentPageNumber, pager } =
    GetArticles.getArticles
        apiUrl
        { request =
            case activeTab of
                ArticleTabs.Personal ->
                    GetArticles.byAuthor maybeToken username

                ArticleTabs.Favourites ->
                    GetArticles.byFavourites maybeToken username
        , page = Pager.toPage currentPageNumber pager
        , onResponse = GotGetArticlesResponse
        }



-- VIEW


type alias ViewOptions msg =
    { zone : Time.Zone
    , viewer : Viewer
    , onChange : Msg -> msg
    }


view : ViewOptions msg -> Model -> H.Html msg
view { zone, viewer, onChange } { username, remoteDataProfile, activeTab, remoteDataArticles, togglingFavourite, currentPageNumber, pager, isDisabled } =
    let
        { role, maybeHeader, content } =
            case viewer of
                Viewer.Guest ->
                    fromGuestToLayoutOptions
                        { zone = zone
                        , remoteDataProfile = remoteDataProfile
                        , activeTab = activeTab
                        , remoteDataArticles = remoteDataArticles
                        , currentPageNumber = currentPageNumber
                        , pager = pager
                        , isDisabled = isDisabled
                        }

                Viewer.User user ->
                    fromUserToLayoutOptions
                        { zone = zone
                        , user = user
                        , profileUsername = username
                        , remoteDataProfile = remoteDataProfile
                        , activeTab = activeTab
                        , remoteDataArticles = remoteDataArticles
                        , togglingFavourite = togglingFavourite
                        , currentPageNumber = currentPageNumber
                        , pager = pager
                        , isDisabled = isDisabled
                        }
    in
    Layout.view
        { name = "profile"
        , role = role
        , maybeHeader = maybeHeader
        }
        content
        |> H.map onChange


type alias LayoutOptions msg =
    { role : Navigation.Role
    , maybeHeader : Maybe (H.Html msg)
    , content : List (H.Html msg)
    }


fromGuestToLayoutOptions :
    { zone : Time.Zone
    , remoteDataProfile : RemoteData () GetProfile.Profile
    , activeTab : ArticleTabs.Tab
    , remoteDataArticles : RemoteData () (List Article)
    , currentPageNumber : PageNumber
    , pager : Pager
    , isDisabled : Bool
    }
    -> LayoutOptions Msg
fromGuestToLayoutOptions { zone, remoteDataProfile, activeTab, remoteDataArticles, currentPageNumber, pager, isDisabled } =
    let
        { maybeHeader, content } =
            case remoteDataProfile of
                RemoteData.Loading ->
                    { maybeHeader = Nothing
                    , content = []
                    }

                RemoteData.Success profile ->
                    { maybeHeader =
                        Just <|
                            viewProfileHeader
                                { profile = profile
                                , role = ProfileHeader.Guest
                                }
                    , content =
                        [ Column.viewSingle Column.Medium <|
                            ArticleTabs.view
                                { activeTab = activeTab
                                , isDisabled = isDisabled
                                , onSwitch = SwitchedArticleTabs
                                }
                                :: viewArticles
                                    { zone = zone
                                    , activeTab = activeTab
                                    , remoteDataArticles = remoteDataArticles
                                    , currentPageNumber = currentPageNumber
                                    , pager = pager
                                    , toRole = always ArticlePreview.Guest
                                    }
                        ]
                    }

                RemoteData.Failure () ->
                    { maybeHeader = Nothing
                    , content = [ viewProfileFailure ]
                    }
    in
    { role = Navigation.guest
    , maybeHeader = maybeHeader
    , content = content
    }


fromUserToLayoutOptions :
    { zone : Time.Zone
    , user : User
    , profileUsername : Username
    , remoteDataProfile : RemoteData () GetProfile.Profile
    , activeTab : ArticleTabs.Tab
    , remoteDataArticles : RemoteData () (List Article)
    , togglingFavourite : Maybe Slug
    , currentPageNumber : PageNumber
    , pager : Pager
    , isDisabled : Bool
    }
    -> LayoutOptions Msg
fromUserToLayoutOptions { zone, user, profileUsername, remoteDataProfile, activeTab, remoteDataArticles, togglingFavourite, currentPageNumber, pager, isDisabled } =
    let
        { maybeHeader, content } =
            case remoteDataProfile of
                RemoteData.Loading ->
                    { maybeHeader = Nothing
                    , content = []
                    }

                RemoteData.Success profile ->
                    { maybeHeader =
                        Just <|
                            viewProfileHeader
                                { profile = profile
                                , role =
                                    if user.username == profile.username then
                                        ProfileHeader.Owner

                                    else
                                        let
                                            toToggledFollowMsg =
                                                ToggledFollow user.token profile.username
                                        in
                                        ProfileHeader.User
                                            { isFollowing = profile.isFollowing
                                            , isDisabled = isDisabled
                                            , onFollow = toToggledFollowMsg True
                                            , onUnfollow = toToggledFollowMsg False
                                            }
                                }
                    , content =
                        [ Column.viewSingle Column.Medium <|
                            ArticleTabs.view
                                { activeTab = activeTab
                                , isDisabled = isDisabled
                                , onSwitch = SwitchedArticleTabs
                                }
                                :: viewArticles
                                    { zone = zone
                                    , activeTab = activeTab
                                    , remoteDataArticles = remoteDataArticles
                                    , currentPageNumber = currentPageNumber
                                    , pager = pager
                                    , toRole =
                                        \{ slug, isFavourite, totalFavourites } ->
                                            ArticlePreview.User
                                                { isLoading = togglingFavourite == Just slug
                                                , totalFavourites = totalFavourites
                                                , isFavourite = isFavourite
                                                , onToggleFavourite = ToggledFavourite user.token slug
                                                }
                                    }
                        ]
                    }

                RemoteData.Failure () ->
                    { maybeHeader = Nothing
                    , content = [ viewProfileFailure ]
                    }
    in
    { role =
        let
            userDetails =
                { username = user.username
                , imageUrl = user.imageUrl
                }
        in
        if user.username == profileUsername then
            Navigation.profile userDetails

        else
            Navigation.user userDetails
    , maybeHeader = maybeHeader
    , content = content
    }


viewProfileHeader :
    { profile : GetProfile.Profile
    , role : ProfileHeader.Role msg
    }
    -> H.Html msg
viewProfileHeader { profile, role } =
    ProfileHeader.view
        { username = profile.username
        , imageUrl = profile.imageUrl
        , bio = profile.bio
        , role = role
        }


viewArticles :
    { zone : Time.Zone
    , activeTab : ArticleTabs.Tab
    , remoteDataArticles : RemoteData () (List Article)
    , currentPageNumber : PageNumber
    , pager : Pager
    , toRole : Article -> ArticlePreview.Role Msg
    }
    -> List (H.Html Msg)
viewArticles { zone, activeTab, remoteDataArticles, currentPageNumber, pager, toRole } =
    case remoteDataArticles of
        RemoteData.Loading ->
            [ ArticlePreview.viewMessage "Loading articles..." ]

        RemoteData.Success articles ->
            if List.isEmpty articles then
                case activeTab of
                    ArticleTabs.Personal ->
                        [ ArticlePreview.viewMessage "Write some articles to populate this tab." ]

                    ArticleTabs.Favourites ->
                        [ ArticlePreview.viewMessage "Favourite some articles to populate this tab." ]

            else
                List.concat
                    [ List.map
                        (\({ slug, title, description, tags, createdAt, author } as article) ->
                            ArticlePreview.view
                                { role = toRole article
                                , username = author.username
                                , imageUrl = author.imageUrl
                                , zone = zone
                                , createdAt = createdAt
                                , slug = slug
                                , title = title
                                , description = description
                                , tags = tags
                                }
                        )
                        articles
                    , [ Pagination.view
                            { totalPages = Pager.toTotalPages pager
                            , currentPageNumber = currentPageNumber
                            , onChangePageNumber = ChangedPageNumber
                            }
                      ]
                    ]

        RemoteData.Failure () ->
            [ ArticlePreview.viewMessage "Unable to load the articles." ]


viewProfileFailure : H.Html msg
viewProfileFailure =
    H.p [] [ H.text "Unable to load the user's profile." ]
