module Page.Home exposing (InitOptions, Model, Msg, UpdateOptions, ViewOptions, init, update, view)

import Api
import Api.GetArticles as GetArticles
import Api.GetTags as GetTags
import Api.ToggleFavourite as ToggleFavourite
import Data.Article exposing (Article)
import Data.Limit as Limit
import Data.Offset as Offset
import Data.PageNumber as PageNumber exposing (PageNumber)
import Data.Pager as Pager exposing (Pager)
import Data.Slug as Slug exposing (Slug)
import Data.Tag as Tag exposing (Tag)
import Data.Timestamp as Timestamp
import Data.Token exposing (Token)
import Data.Total as Total exposing (Total)
import Data.Username as Username
import Data.Viewer as Viewer exposing (Viewer)
import Html as H
import Html.Attributes as HA
import Lib.RemoteData as RemoteData exposing (RemoteData)
import Lib.Task as Task
import Time
import Url exposing (Url)
import View.ArticlePreview as ArticlePreview
import View.Column as Column
import View.FeedTabs as FeedTabs
import View.HomeHeader as HomeHeader
import View.Layout as Layout
import View.Navigation as Navigation
import View.Pagination as Pagination
import View.Sidebar as Sidebar



-- MODEL


type alias Model =
    { activeTab : FeedTabs.Tab
    , maybeTag : Maybe Tag
    , feed : Feed
    , togglingFavourite : Maybe Slug
    , remoteDataTags : RemoteData () (List Tag)
    }


type alias Feed =
    { remoteDataArticles : RemoteData () (List Article)
    , currentPageNumber : PageNumber
    , pager : Pager
    }



--
-- TODO: Try implementing the below in terms of
--
-- updateFeed : (Feed -> Feed) -> Model -> Model
--


feedInit : Feed
feedInit =
    { remoteDataArticles = RemoteData.Loading
    , currentPageNumber = PageNumber.one
    , pager = Pager.ten
    }


feedSetRemoteDataArticles : RemoteData () (List Article) -> Feed -> Feed
feedSetRemoteDataArticles remoteDataArticles feed =
    { feed | remoteDataArticles = remoteDataArticles }


feedSetCurrentPageNumber : PageNumber -> Feed -> Feed
feedSetCurrentPageNumber pageNumber feed =
    { feed | currentPageNumber = pageNumber }


feedSetTotalPages : Total -> Feed -> Feed
feedSetTotalPages totalPages feed =
    { feed | pager = Pager.setTotalPages totalPages feed.pager }


feedToPage : Feed -> Pager.Page
feedToPage { currentPageNumber, pager } =
    Pager.toPage currentPageNumber pager


feedUpdateFavourite : ToggleFavourite.TotalFavourites -> Feed -> Feed
feedUpdateFavourite { slug, isFavourite, totalFavourites } feed =
    let
        remoteDataArticles =
            RemoteData.map
                (List.map
                    (\article ->
                        if article.slug == slug then
                            { article | isFavourite = isFavourite, totalFavourites = totalFavourites }

                        else
                            article
                    )
                )
                feed.remoteDataArticles
    in
    { feed | remoteDataArticles = remoteDataArticles }


type alias InitOptions msg =
    { apiUrl : Url
    , viewer : Viewer
    , onChange : Msg -> msg
    }


init : InitOptions msg -> ( Model, Cmd msg )
init { apiUrl, viewer, onChange } =
    let
        feed =
            feedInit

        { activeTab, getArticlesCmd } =
            case viewer of
                Viewer.Guest ->
                    { activeTab = FeedTabs.Global
                    , getArticlesCmd = getGlobalArticles Nothing apiUrl feed
                    }

                Viewer.User { token } ->
                    { activeTab = FeedTabs.Personal
                    , getArticlesCmd = getPersonalArticles token apiUrl feed
                    }

        getTagsCmd =
            GetTags.getTags apiUrl { onResponse = GotTagsResponse }

        cmd =
            Cmd.batch
                [ getArticlesCmd
                , getTagsCmd
                ]
    in
    ( { activeTab = activeTab
      , maybeTag = Nothing
      , feed = feed
      , togglingFavourite = Nothing
      , remoteDataTags = RemoteData.Loading
      }
    , Cmd.map onChange cmd
    )



-- UPDATE


type Msg
    = GotArticlesResponse (Result (Api.Error ()) GetArticles.Articles)
    | GotTagsResponse (Result (Api.Error ()) GetTags.Tags)
    | SwitchedFeedTabs FeedTabs.Tab
    | ClickedTag Tag
    | ChangedPageNumber PageNumber
    | ToggledFavourite Token Slug Bool
    | GotToggleFavouriteResponse (Result (Api.Error ()) ToggleFavourite.TotalFavourites)


type alias UpdateOptions msg =
    { apiUrl : Url
    , viewer : Viewer
    , onChange : Msg -> msg
    }


update : UpdateOptions msg -> Msg -> Model -> ( Model, Cmd msg )
update options msg model =
    updateHelper options msg model
        |> Tuple.mapSecond (Cmd.map options.onChange)


updateHelper : UpdateOptions msg -> Msg -> Model -> ( Model, Cmd Msg )
updateHelper options msg model =
    case msg of
        GotArticlesResponse result ->
            case result of
                Ok { articles, totalArticles } ->
                    let
                        feed =
                            model.feed
                                |> feedSetRemoteDataArticles (RemoteData.Success articles)
                                |> feedSetTotalPages totalArticles
                    in
                    ( { model | feed = feed }
                    , Cmd.none
                    )

                Err _ ->
                    let
                        feed =
                            model.feed
                                |> feedSetRemoteDataArticles (RemoteData.Failure ())
                    in
                    ( { model | feed = feed }
                    , Cmd.none
                    )

        GotTagsResponse result ->
            case result of
                Ok tags ->
                    ( { model | remoteDataTags = RemoteData.Success tags }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | remoteDataTags = RemoteData.Failure () }
                    , Cmd.none
                    )

        SwitchedFeedTabs tab ->
            let
                feed =
                    feedInit
            in
            ( { model
                | activeTab = tab
                , feed = feed
              }
            , getArticles tab options.viewer options.apiUrl feed
            )

        ClickedTag tag ->
            let
                feed =
                    feedInit
            in
            ( { model
                | activeTab = FeedTabs.Tag tag
                , maybeTag = Just tag
                , feed = feed
              }
            , getArticlesByTag (Viewer.toToken options.viewer) tag options.apiUrl feed
            )

        ChangedPageNumber pageNumber ->
            let
                feed =
                    model.feed
                        |> feedSetRemoteDataArticles RemoteData.Loading
                        |> feedSetCurrentPageNumber pageNumber
            in
            ( { model | feed = feed }
            , getArticles model.activeTab options.viewer options.apiUrl feed
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
            )

        GotToggleFavouriteResponse result ->
            let
                newModel =
                    { model | togglingFavourite = Nothing }
            in
            case result of
                Ok totalFavourites ->
                    ( { newModel | feed = feedUpdateFavourite totalFavourites model.feed }
                    , Cmd.none
                    )

                Err _ ->
                    ( newModel
                    , Cmd.none
                    )



-- HTTP


getArticles : FeedTabs.Tab -> Viewer -> Url -> Feed -> Cmd Msg
getArticles tab viewer =
    let
        maybeToken =
            Viewer.toToken viewer
    in
    case tab of
        FeedTabs.Personal ->
            case maybeToken of
                Just token ->
                    getPersonalArticles token

                Nothing ->
                    --
                    -- N.B. This should NEVER happen.
                    --
                    Task.dispatch (GotArticlesResponse (Err Api.Unauthorized))
                        |> always
                        |> always

        FeedTabs.Global ->
            getGlobalArticles maybeToken

        FeedTabs.Tag tag ->
            getArticlesByTag maybeToken tag


getPersonalArticles : Token -> Url -> Feed -> Cmd Msg
getPersonalArticles token apiUrl feed =
    GetArticles.getArticles
        apiUrl
        { request = GetArticles.fromUsersYouFollow token
        , page = feedToPage feed
        , onResponse = GotArticlesResponse
        }


getGlobalArticles : Maybe Token -> Url -> Feed -> Cmd Msg
getGlobalArticles maybeToken apiUrl feed =
    GetArticles.getArticles
        apiUrl
        { request = GetArticles.global maybeToken
        , page = feedToPage feed
        , onResponse = GotArticlesResponse
        }


getArticlesByTag : Maybe Token -> Tag -> Url -> Feed -> Cmd Msg
getArticlesByTag maybeToken tag apiUrl feed =
    GetArticles.getArticles
        apiUrl
        { request = GetArticles.byTag maybeToken tag
        , page = feedToPage feed
        , onResponse = GotArticlesResponse
        }



-- VIEW


type alias ViewOptions msg =
    { zone : Time.Zone
    , viewer : Viewer
    , onChange : Msg -> msg
    }


view : ViewOptions msg -> Model -> H.Html msg
view { zone, viewer, onChange } model =
    let
        feed =
            model.feed

        ( role, hasPersonal ) =
            case viewer of
                Viewer.Guest ->
                    ( Navigation.guestHome
                    , False
                    )

                Viewer.User { username, imageUrl } ->
                    ( Navigation.userHome
                        { username = username
                        , imageUrl = imageUrl
                        }
                    , True
                    )

        viewFeedTabs =
            [ FeedTabs.view
                { hasPersonal = hasPersonal
                , maybeTag = model.maybeTag
                , activeTab = model.activeTab
                , isDisabled = isLoadingFeed
                , onSwitch = SwitchedFeedTabs
                }
            ]

        ( isLoadingFeed, viewArticlePreviews ) =
            case feed.remoteDataArticles of
                RemoteData.Loading ->
                    ( True
                    , [ ArticlePreview.viewMessage "Loading articles..." ]
                    )

                RemoteData.Success articles ->
                    ( False
                    , case ( model.activeTab, articles ) of
                        ( FeedTabs.Personal, [] ) ->
                            [ ArticlePreview.viewMessage "Follow some users to populate this feed." ]

                        _ ->
                            List.map (viewArticlePreview viewer zone model.togglingFavourite) articles
                    )

                RemoteData.Failure _ ->
                    ( False
                    , [ ArticlePreview.viewMessage "Unable to load the articles." ]
                    )

        viewPagination =
            [ Pagination.view
                { totalPages = Pager.toTotalPages feed.pager
                , currentPageNumber = feed.currentPageNumber
                , onChangePageNumber = ChangedPageNumber
                }
            ]

        viewSidebar =
            Sidebar.view <|
                case model.remoteDataTags of
                    RemoteData.Loading ->
                        Sidebar.Loading

                    RemoteData.Success tags ->
                        Sidebar.Tags
                            { tags = tags
                            , activeTag = FeedTabs.activeTag model.activeTab
                            , onClick = ClickedTag
                            }

                    RemoteData.Failure _ ->
                        Sidebar.Error "Unable to load the tags."
    in
    Layout.view
        { name = "home"
        , role = role
        , maybeHeader = Just HomeHeader.view
        }
        [ Column.viewDouble
            { left =
                List.concat
                    [ viewFeedTabs
                    , viewArticlePreviews
                    , viewPagination
                    ]
            , right =
                [ viewSidebar
                ]
            }
        ]
        |> H.map onChange


viewArticlePreview : Viewer -> Time.Zone -> Maybe Slug -> Article -> H.Html Msg
viewArticlePreview viewer zone togglingFavourite article =
    ArticlePreview.view
        { role =
            case viewer of
                Viewer.Guest ->
                    ArticlePreview.Guest

                Viewer.User { token } ->
                    ArticlePreview.User
                        { isLoading = togglingFavourite == Just article.slug
                        , totalFavourites = article.totalFavourites
                        , isFavourite = article.isFavourite
                        , onToggleFavourite = ToggledFavourite token article.slug
                        }
        , username = article.author.username
        , imageUrl = article.author.imageUrl
        , zone = zone
        , createdAt = article.createdAt
        , slug = article.slug
        , title = article.title
        , description = article.description
        , tags = article.tags
        }
