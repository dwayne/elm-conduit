module Page.Profile exposing (InitOptions, Model, Msg, UpdateOptions, ViewOptions, init, update, view)

import Api
import Api.GetArticles as GetArticles
import Api.GetProfile as GetProfile
import Data.Article as Article exposing (Article)
import Data.PageNumber as PageNumber exposing (PageNumber)
import Data.Pager as Pager exposing (Pager)
import Data.Token exposing (Token)
import Data.User exposing (User)
import Data.Username exposing (Username)
import Data.Viewer as Viewer exposing (Viewer)
import Html as H
import Html.Attributes as HA
import Lib.RemoteData as RemoteData exposing (RemoteData)
import Time
import Url exposing (Url)
import View.ArticlePreview as ArticlePreview
import View.ArticleTabs as ArticleTabs
import View.Navigation as Navigation
import View.Pagination as Pagination
import View.ProfileHeader as ProfileHeader



-- MODEL


type alias Model =
    { remoteDataProfile : RemoteData () GetProfile.Profile
    , showFavourites : Bool
    , remoteDataArticles : RemoteData () (List Article)
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
        currentPageNumber =
            PageNumber.one

        pager =
            Pager.five
    in
    ( { remoteDataProfile = RemoteData.Loading
      , showFavourites = showFavourites
      , remoteDataArticles = RemoteData.Loading
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
      , GetArticles.getArticles
            apiUrl
            { request =
                if showFavourites then
                    GetArticles.byFavourites maybeToken username

                else
                    GetArticles.byAuthor maybeToken username
            , page = Pager.toPage currentPageNumber pager
            , onResponse = GotGetArticlesResponse
            }
      ]
        |> Cmd.batch
        |> Cmd.map onChange
    )



-- UPDATE


type Msg
    = NoOp
    | GotGetProfileResponse (Result (Api.Error ()) GetProfile.Profile)
    | GotGetArticlesResponse (Result (Api.Error ()) GetArticles.Articles)


type alias UpdateOptions msg =
    { apiUrl : Url
    , onChange : Msg -> msg
    }


update : UpdateOptions msg -> Msg -> Model -> ( Model, Cmd msg )
update _ msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )

        GotGetProfileResponse result ->
            ( result
                |> Result.map
                    (\profile ->
                        { model | remoteDataProfile = RemoteData.Success profile }
                    )
                |> Result.withDefault model
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
                |> Result.withDefault model
            , Cmd.none
            )



-- VIEW


type alias ViewOptions msg =
    { zone : Time.Zone
    , viewer : Viewer
    , onChange : Msg -> msg
    }


view : ViewOptions msg -> Model -> H.Html msg
view { zone, viewer, onChange } { remoteDataProfile, showFavourites, remoteDataArticles, currentPageNumber, pager, isDisabled } =
    let
        viewHelper =
            case viewer of
                Viewer.Guest ->
                    viewAsGuest
                        { zone = zone
                        , remoteDataProfile = remoteDataProfile
                        , showFavourites = showFavourites
                        , remoteDataArticles = remoteDataArticles
                        , currentPageNumber = currentPageNumber
                        , pager = pager
                        , isDisabled = isDisabled
                        }

                Viewer.User user ->
                    viewAsUser
                        { zone = zone
                        , user = user
                        , remoteDataProfile = remoteDataProfile
                        , showFavourites = showFavourites
                        , remoteDataArticles = remoteDataArticles
                        , currentPageNumber = currentPageNumber
                        , pager = pager
                        , isDisabled = isDisabled
                        }
    in
    H.map onChange viewHelper


viewAsGuest :
    { zone : Time.Zone
    , remoteDataProfile : RemoteData () GetProfile.Profile
    , showFavourites : Bool
    , remoteDataArticles : RemoteData () (List Article)
    , currentPageNumber : PageNumber
    , pager : Pager
    , isDisabled : Bool
    }
    -> H.Html Msg
viewAsGuest { zone, remoteDataProfile, showFavourites, remoteDataArticles, currentPageNumber, pager, isDisabled } =
    H.div []
        [ Navigation.view { role = Navigation.guest }
        , viewProfilePage
            (\profile ->
                [ viewProfileHeader
                    { profile = profile
                    , role = ProfileHeader.Guest
                    }
                , viewRow <|
                    [ viewArticleTabs
                        { showFavourites = showFavourites
                        , isDisabled = isDisabled
                        }
                    ]
                        ++ viewArticles
                            { zone = zone
                            , remoteDataArticles = remoteDataArticles
                            , currentPageNumber = currentPageNumber
                            , pager = pager
                            , toRole = always ArticlePreview.Guest
                            }
                ]
            )
            remoteDataProfile
        ]


viewAsUser :
    { zone : Time.Zone
    , user : User
    , remoteDataProfile : RemoteData () GetProfile.Profile
    , showFavourites : Bool
    , remoteDataArticles : RemoteData () (List Article)
    , currentPageNumber : PageNumber
    , pager : Pager
    , isDisabled : Bool
    }
    -> H.Html Msg
viewAsUser { zone, user, remoteDataProfile, showFavourites, remoteDataArticles, currentPageNumber, pager, isDisabled } =
    H.div []
        [ Navigation.view
            { role =
                Navigation.profile
                    { username = user.username
                    , imageUrl = user.imageUrl
                    }
            }
        , viewProfilePage
            (\profile ->
                [ viewProfileHeader
                    { profile = profile
                    , role =
                        if user.username == profile.username then
                            ProfileHeader.Owner

                        else
                            ProfileHeader.User
                                { isFollowing = profile.isFollowing

                                --
                                -- TODO: Implement follow/unfollow.
                                --
                                , isDisabled = isDisabled
                                , onFollow = NoOp
                                , onUnfollow = NoOp
                                }
                    }
                , viewRow <|
                    [ viewArticleTabs
                        { showFavourites = showFavourites
                        , isDisabled = isDisabled
                        }
                    ]
                        ++ viewArticles
                            { zone = zone
                            , remoteDataArticles = remoteDataArticles
                            , currentPageNumber = currentPageNumber
                            , pager = pager
                            , toRole =
                                \{ isFavourite, totalFavourites } ->
                                    ArticlePreview.User
                                        { isLoading = isDisabled
                                        , totalFavourites = totalFavourites
                                        , isFavourite = isFavourite

                                        --
                                        -- TODO: Implement onToggleFavourite.
                                        --
                                        , onToggleFavourite = always NoOp
                                        }
                            }
                ]
            )
            remoteDataProfile
        ]


viewProfilePage : (GetProfile.Profile -> List (H.Html msg)) -> RemoteData () GetProfile.Profile -> H.Html msg
viewProfilePage toHtml remoteDataProfile =
    H.div [ HA.class "profile-page" ] <|
        case remoteDataProfile of
            RemoteData.Loading ->
                []

            RemoteData.Success profile ->
                toHtml profile

            RemoteData.Failure _ ->
                [ H.text "Unable to load the user's profile." ]


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


viewArticleTabs :
    { showFavourites : Bool
    , isDisabled : Bool
    }
    -> H.Html Msg
viewArticleTabs { showFavourites, isDisabled } =
    ArticleTabs.view
        { activeTab =
            if showFavourites then
                ArticleTabs.Favourites

            else
                ArticleTabs.Personal

        --
        -- TODO: Implement onSwitch.
        --
        , isDisabled = isDisabled
        , onSwitch = always NoOp
        }


viewArticles :
    { zone : Time.Zone
    , remoteDataArticles : RemoteData () (List Article)
    , currentPageNumber : PageNumber
    , pager : Pager
    , toRole : Article -> ArticlePreview.Role Msg
    }
    -> List (H.Html Msg)
viewArticles { zone, remoteDataArticles, currentPageNumber, pager, toRole } =
    case remoteDataArticles of
        RemoteData.Loading ->
            []

        RemoteData.Success articles ->
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

                        --
                        -- TODO: Implement onChangePageNumber.
                        --
                        , onChangePageNumber = always NoOp
                        }
                  ]
                ]

        RemoteData.Failure _ ->
            [ H.text "Unable to load articles." ]


viewRow : List (H.Html msg) -> H.Html msg
viewRow rows =
    H.div
        [ HA.class "container" ]
        [ H.div
            [ HA.class "row" ]
            [ H.div
                [ HA.class "col-xs-12 col-md-10 offset-md-1" ]
                rows
            ]
        ]
