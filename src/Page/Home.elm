module Page.Home exposing (Model, Msg, ViewOptions, init, update, view)

import Api
import Api.GetArticles as GetArticles
import Api.GetTags as GetTags
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
import Time
import View.ArticlePreview as ArticlePreview
import View.FeedTabs as FeedTabs
import View.Footer as Footer
import View.HomeHeader as HomeHeader
import View.Navigation as Navigation
import View.Pagination as Pagination
import View.Sidebar as Sidebar


type alias Model =
    { activeTab : FeedTabs.Tab
    , maybeTag : Maybe Tag
    , feed : Feed
    , remoteDataTags : RemoteData () (List Tag)
    }


type alias Feed =
    { remoteDataArticles : RemoteData () (List GetArticles.Article)
    , pager : Pager
    , currentPageNumber : PageNumber
    }


initFeed : Feed
initFeed =
    { remoteDataArticles = RemoteData.Loading
    , pager = Pager.new
    , currentPageNumber = PageNumber.one
    }


setFeedRemoteDataArtciles : RemoteData () (List GetArticles.Article) -> Feed -> Feed
setFeedRemoteDataArtciles remoteDataArticles feed =
    { feed | remoteDataArticles = remoteDataArticles }


setFeedTotalPages : Total -> Feed -> Feed
setFeedTotalPages totalPages feed =
    { feed | pager = Pager.setTotalPages totalPages feed.pager }


setFeedCurrentPageNumber : PageNumber -> Feed -> Feed
setFeedCurrentPageNumber pageNumber feed =
    { feed | currentPageNumber = pageNumber }


type alias InitOptions msg =
    { apiUrl : String
    , viewer : Viewer
    , onChange : Msg -> msg
    }


init : InitOptions msg -> ( Model, Cmd msg )
init { apiUrl, viewer, onChange } =
    let
        feed =
            initFeed

        { activeTab, getArticlesCmd } =
            case viewer of
                Viewer.Guest ->
                    { activeTab = FeedTabs.Global
                    , getArticlesCmd = getGlobalFeedArticles apiUrl feed
                    }

                Viewer.User { token } ->
                    { activeTab = FeedTabs.Personal
                    , getArticlesCmd = getPersonalFeedArticles token apiUrl feed
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
      , remoteDataTags = RemoteData.Loading
      }
    , Cmd.map onChange cmd
    )



-- UPDATE


type alias UpdateOptions msg =
    { apiUrl : String
    , viewer : Viewer
    , onChange : Msg -> msg
    }


type Msg
    = GotArticlesResponse (Result (Api.Error ()) GetArticles.Articles)
    | GotTagsResponse (Result (Api.Error ()) GetTags.Tags)
    | SwitchedFeedTabs FeedTabs.Tab
    | ClickedTag Tag
    | ChangedPageNumber PageNumber
    | ToggledFavourite Slug Bool


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
                                |> setFeedRemoteDataArtciles (RemoteData.Success articles)
                                |> setFeedTotalPages totalArticles
                    in
                    ( { model | feed = feed }
                    , Cmd.none
                    )

                Err _ ->
                    let
                        feed =
                            model.feed
                                |> setFeedRemoteDataArtciles (RemoteData.Failure ())
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
                    initFeed
            in
            ( { model
                | activeTab = tab
                , feed = feed
              }
            , getFeedArticles tab options.viewer options.apiUrl feed
            )

        ClickedTag tag ->
            let
                feed =
                    initFeed
            in
            ( { model
                | activeTab = FeedTabs.Tag tag
                , maybeTag = Just tag
                , feed = feed
              }
            , getTagFeedArticles tag options.apiUrl feed
            )

        ChangedPageNumber pageNumber ->
            let
                feed =
                    model.feed
                        |> setFeedRemoteDataArtciles RemoteData.Loading
                        |> setFeedCurrentPageNumber pageNumber
            in
            ( { model | feed = feed }
            , getFeedArticles model.activeTab options.viewer options.apiUrl feed
            )

        ToggledFavourite slug isFavourite ->
            --
            -- TODO: Toggle favourite.
            --
            ( model, Cmd.none )



-- HTTP


getFeedArticles : FeedTabs.Tab -> Viewer -> String -> Feed -> Cmd Msg
getFeedArticles tab viewer =
    case tab of
        FeedTabs.Personal ->
            case viewer of
                Viewer.User { token } ->
                    getPersonalFeedArticles token

                Viewer.Guest ->
                    --
                    -- N.B. This should NEVER happen.
                    --
                    always <| always Cmd.none

        FeedTabs.Global ->
            getGlobalFeedArticles

        FeedTabs.Tag tag ->
            getTagFeedArticles tag


getPersonalFeedArticles : Token -> String -> Feed -> Cmd Msg
getPersonalFeedArticles token apiUrl { pager, currentPageNumber } =
    GetArticles.getArticles
        apiUrl
        { request = GetArticles.fromUsersYouFollow token
        , page = Pager.toPage currentPageNumber pager
        , onResponse = GotArticlesResponse
        }


getGlobalFeedArticles : String -> Feed -> Cmd Msg
getGlobalFeedArticles apiUrl { pager, currentPageNumber } =
    GetArticles.getArticles
        apiUrl
        { request = GetArticles.global
        , page = Pager.toPage currentPageNumber pager
        , onResponse = GotArticlesResponse
        }


getTagFeedArticles : Tag -> String -> Feed -> Cmd Msg
getTagFeedArticles tag apiUrl { pager, currentPageNumber } =
    GetArticles.getArticles
        apiUrl
        { request = GetArticles.byTag tag
        , page = Pager.toPage currentPageNumber pager
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

        { role, hasPersonal } =
            case viewer of
                Viewer.Guest ->
                    { role = Navigation.guestHome
                    , hasPersonal = False
                    }

                Viewer.User { username, imageUrl } ->
                    { role =
                        Navigation.userHome
                            { username = username
                            , imageUrl = imageUrl
                            }
                    , hasPersonal = True
                    }

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
                            [ ArticlePreview.viewMessage "You need to follow some users to populate this feed." ]

                        _ ->
                            List.map (viewArticlePreview zone) articles
                    )

                RemoteData.Failure _ ->
                    ( False
                    , [ ArticlePreview.viewMessage "Unable to load articles." ]
                    )

        viewPagination =
            [ Pagination.view
                { totalPages = Pager.toTotalPages feed.pager
                , currentPageNumber = feed.currentPageNumber
                , onChangePageNumber = ChangedPageNumber
                }
            ]

        sidebarStatus =
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
                    Sidebar.Error "Unable to load tags."
    in
    H.div []
        [ Navigation.view { role = role }
        , H.div
            [ HA.class "home-page" ]
            [ HomeHeader.view
            , viewColumns
                [ viewFeedTabs
                , viewArticlePreviews
                , viewPagination
                ]
                [ Sidebar.view { status = sidebarStatus }
                ]
            ]
        , Footer.view
        ]
        |> H.map onChange


viewArticlePreview : Time.Zone -> GetArticles.Article -> H.Html Msg
viewArticlePreview zone { slug, title, description, body, tags, createdAt, isFavourite, totalFavourites, author } =
    ArticlePreview.view
        { username = author.username
        , imageUrl = author.imageUrl
        , zone = zone
        , timestamp = createdAt
        , totalFavourites = totalFavourites
        , isFavourite = isFavourite
        , slug = slug
        , title = title
        , description = description
        , tags = tags
        , onToggleFavourite = ToggledFavourite slug
        }


viewColumns : List (List (H.Html msg)) -> List (H.Html msg) -> H.Html msg
viewColumns list col2 =
    let
        col1 =
            List.concat list
    in
    H.div
        [ HA.class "container page" ]
        [ H.div
            [ HA.class "row" ]
            [ H.div [ HA.class "col-md-9" ] col1
            , H.div [ HA.class "col-md-3" ] col2
            ]
        ]
