module Page.Home exposing (Model, Msg, ViewOptions, Viewer(..), init, update, view)

import Api.GetArticles as GetArticles
import Api.GetTags as GetTags
import Data.Limit as Limit
import Data.Offset as Offset
import Data.Pager as Pager exposing (Pager)
import Data.Slug as Slug exposing (Slug)
import Data.Tag as Tag exposing (Tag)
import Data.Timestamp as Timestamp
import Data.Total as Total exposing (Total)
import Data.Username as Username
import Html as H
import Html.Attributes as HA
import Http
import Lib.RemoteData as RemoteData exposing (RemoteData)
import Time
import View.ArticlePreview as ArticlePreview
import View.FeedTabs as FeedTabs
import View.Footer as Footer
import View.HomeHeader as HomeHeader
import View.Navigation as Navigation
import View.Pagination as Pagination
import View.Sidebar as Sidebar


type Viewer
    = Guest
    | User


type alias Model =
    { hasPersonal : Bool
    , activeTab : FeedTabs.Tab
    , tag : String
    , feed : Feed
    , remoteDataTags : RemoteData () (List Tag)
    }


type alias Feed =
    { remoteDataArticles : RemoteData () (List GetArticles.Article)
    , pager : Pager
    , currentPageNumber : Int
    }


initFeed : Feed
initFeed =
    { remoteDataArticles = RemoteData.Loading
    , pager = Pager.new
    , currentPageNumber = 1
    }


setFeedRemoteDataArtciles : RemoteData () (List GetArticles.Article) -> Feed -> Feed
setFeedRemoteDataArtciles remoteDataArticles feed =
    { feed | remoteDataArticles = remoteDataArticles }


setFeedTotalPages : Total -> Feed -> Feed
setFeedTotalPages totalPages feed =
    { feed | pager = Pager.setTotalPages totalPages feed.pager }


setFeedCurrentPageNumber : Int -> Feed -> Feed
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

        { hasPersonal, activeTab, getArticlesCmd } =
            case viewer of
                Guest ->
                    { hasPersonal = False
                    , activeTab = FeedTabs.Global
                    , getArticlesCmd = getGlobalFeedArticles apiUrl feed
                    }

                User ->
                    { hasPersonal = True
                    , activeTab = FeedTabs.Personal
                    , getArticlesCmd = Cmd.none
                    }

        getTagsCmd =
            GetTags.getTags apiUrl { onResponse = GotTagsResponse }

        cmd =
            Cmd.batch
                [ getArticlesCmd
                , getTagsCmd
                ]
    in
    ( { hasPersonal = hasPersonal
      , activeTab = activeTab
      , tag = ""
      , feed = feed
      , remoteDataTags = RemoteData.Loading
      }
    , Cmd.map onChange cmd
    )



-- UPDATE


type alias UpdateOptions msg =
    { apiUrl : String
    , onChange : Msg -> msg
    }


type Msg
    = GotArticlesResponse (Result Http.Error GetArticles.Response)
    | GotTagsResponse (Result Http.Error GetTags.Response)
    | SwitchedFeedTabs FeedTabs.Tab
    | ClickedTag String
    | ClickedPagination Int
    | ToggledFavourite String Bool


update : UpdateOptions msg -> Msg -> Model -> ( Model, Cmd msg )
update options msg model =
    updateHelper options msg model
        |> Tuple.mapSecond (Cmd.map options.onChange)


updateHelper : UpdateOptions msg -> Msg -> Model -> ( Model, Cmd Msg )
updateHelper { apiUrl } msg model =
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
            ( { model | activeTab = tab, feed = feed }
            , getFeedArticles tab apiUrl feed
            )

        ClickedTag tag ->
            let
                feed =
                    initFeed
            in
            ( { model | activeTab = FeedTabs.Tag tag, tag = tag, feed = feed }
            , getTagFeedArticles tag apiUrl feed
            )

        ClickedPagination newPageNumber ->
            let
                feed =
                    model.feed
                        |> setFeedRemoteDataArtciles RemoteData.Loading
                        |> setFeedCurrentPageNumber newPageNumber
            in
            ( { model | feed = feed }
            , getFeedArticles model.activeTab apiUrl feed
            )

        ToggledFavourite slug isFavourite ->
            --
            -- TODO: Toggle favourite.
            --
            ( model, Cmd.none )



-- HTTP


getFeedArticles : FeedTabs.Tab -> String -> Feed -> Cmd Msg
getFeedArticles tab =
    case tab of
        FeedTabs.Personal ->
            getPersonalFeedArticles

        FeedTabs.Global ->
            getGlobalFeedArticles

        FeedTabs.Tag tag ->
            getTagFeedArticles tag


getPersonalFeedArticles : String -> Feed -> Cmd Msg
getPersonalFeedArticles _ _ =
    --
    -- TODO: Get articles for the personal feed.
    --
    Cmd.none


getGlobalFeedArticles : String -> Feed -> Cmd Msg
getGlobalFeedArticles apiUrl { pager, currentPageNumber } =
    GetArticles.getArticles
        apiUrl
        { filter = GetArticles.Global
        , page = Pager.toPage currentPageNumber pager
        , onResponse = GotArticlesResponse
        }


getTagFeedArticles : String -> String -> Feed -> Cmd Msg
getTagFeedArticles tagAsString apiUrl { pager, currentPageNumber } =
    case Tag.fromString tagAsString of
        Just tag ->
            GetArticles.getArticles
                apiUrl
                { filter = GetArticles.ByTag tag
                , page = Pager.toPage currentPageNumber pager
                , onResponse = GotArticlesResponse
                }

        Nothing ->
            Cmd.none



-- VIEW


type alias ViewOptions msg =
    { zone : Time.Zone
    , onChange : Msg -> msg
    }


view : ViewOptions msg -> Model -> H.Html msg
view { zone, onChange } model =
    let
        feed =
            model.feed

        viewFeedTabs =
            [ FeedTabs.view
                { hasPersonal = model.hasPersonal
                , tag = model.tag
                , activeTab = model.activeTab
                , isDisabled = isLoadingFeed
                , onSwitch = SwitchedFeedTabs
                }
            ]

        ( isLoadingFeed, viewArticlePreviews ) =
            case feed.remoteDataArticles of
                RemoteData.Loading ->
                    ( True
                    , [ H.div
                            [ HA.class "article-preview" ]
                            [ H.text "Loading articles..." ]
                      ]
                    )

                RemoteData.Success articles ->
                    ( False
                    , List.map (viewArticlePreview zone) articles
                    )

                RemoteData.Failure _ ->
                    ( False
                    , [ H.div
                            [ HA.class "article-preview" ]
                            [ H.text "Unable to load articles." ]
                      ]
                    )

        viewPagination =
            [ Pagination.view
                { totalPages =
                    feed.pager
                        |> Pager.toTotalPages
                        |> Total.toInt
                , currentPageNumber = feed.currentPageNumber
                , onClick = ClickedPagination
                }
            ]

        viewSidebar =
            Sidebar.view <|
                case model.remoteDataTags of
                    RemoteData.Loading ->
                        Sidebar.Loading

                    RemoteData.Success tags ->
                        Sidebar.Tags
                            { tags = List.map Tag.toString tags
                            , activeTag = FeedTabs.activeTag model.activeTab
                            , onClick = ClickedTag
                            }

                    RemoteData.Failure _ ->
                        Sidebar.Error "Unable to load tags."
    in
    H.div []
        [ Navigation.view { role = Navigation.guestHome }
        , H.div
            [ HA.class "home-page" ]
            [ HomeHeader.view
            , viewColumns
                [ viewFeedTabs
                , viewArticlePreviews
                , viewPagination
                ]
                [ viewSidebar
                ]
            ]
        , Footer.view
        ]
        |> H.map onChange


viewArticlePreview : Time.Zone -> GetArticles.Article -> H.Html Msg
viewArticlePreview zone { slug, title, description, body, tags, createdAt, isFavourite, totalFavourites, author } =
    let
        slugAsString =
            Slug.toString slug
    in
    ArticlePreview.view
        { name = Username.toString author.username
        , imageUrl = author.imageUrl
        , date = Timestamp.toString zone createdAt
        , totalFavourites = Total.toInt totalFavourites
        , isFavourite = isFavourite
        , slug = slugAsString
        , title = title
        , description = description
        , tags = List.map Tag.toString tags
        , onToggleFavourite = ToggledFavourite slugAsString
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
