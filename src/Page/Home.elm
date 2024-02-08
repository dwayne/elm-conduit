module Page.Home exposing (Model, Msg, ViewOptions, Viewer(..), init, update, view)

import Api.GetArticles as GetArticles
import Api.GetTags as GetTags
import Data.Limit as Limit
import Data.Offset as Offset
import Data.Pager as Pager exposing (Pager)
import Data.Slug as Slug exposing (Slug)
import Data.Tag as Tag exposing (Tag)
import Data.Timestamp as Timestamp
import Data.Total as Total
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
    { remoteDataArticles : RemoteData () (List GetArticles.Article)
    , remoteDataTags : RemoteData () (List Tag)
    , hasPersonal : Bool
    , tag : String
    , activeTab : FeedTabs.Tab
    , globalFeed : GlobalFeed
    }


type alias GlobalFeed =
    { pager : Pager
    , currentPageNumber : Int
    }


initGlobalFeed : GlobalFeed
initGlobalFeed =
    { pager = Pager.new
    , currentPageNumber = 1
    }


type alias InitOptions msg =
    { apiUrl : String
    , viewer : Viewer
    , onChange : Msg -> msg
    }


init : InitOptions msg -> ( Model, Cmd msg )
init { apiUrl, viewer, onChange } =
    let
        globalFeed =
            initGlobalFeed

        { hasPersonal, activeTab, getArticlesCmd } =
            case viewer of
                Guest ->
                    { hasPersonal = False
                    , activeTab = FeedTabs.Global
                    , getArticlesCmd = getGlobalFeedArticles apiUrl globalFeed
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
    ( { remoteDataArticles = RemoteData.Loading
      , remoteDataTags = RemoteData.Loading
      , hasPersonal = hasPersonal
      , tag = ""
      , activeTab = activeTab
      , globalFeed = globalFeed
      }
    , Cmd.map onChange cmd
    )


getGlobalFeedArticles : String -> GlobalFeed -> Cmd Msg
getGlobalFeedArticles apiUrl { currentPageNumber, pager } =
    GetArticles.getArticles
        apiUrl
        { filter = GetArticles.Global
        , page = Pager.toPage currentPageNumber pager
        , onResponse = GotGlobalFeedArticlesResponse
        }



-- UPDATE


type alias UpdateOptions msg =
    { apiUrl : String
    , onChange : Msg -> msg
    }


type Msg
    = NoOp
    | GotGlobalFeedArticlesResponse (Result Http.Error GetArticles.Response)
    | GotTagsResponse (Result Http.Error GetTags.Response)
    | SwitchedFeedTabs FeedTabs.Tab
    | ToggledFavourite Slug Bool
    | ClickedGlobalFeedPagination Int
    | ClickedTag String


update : UpdateOptions msg -> Msg -> Model -> ( Model, Cmd msg )
update options msg model =
    updateHelper options msg model
        |> Tuple.mapSecond (Cmd.map options.onChange)


updateHelper : UpdateOptions msg -> Msg -> Model -> ( Model, Cmd Msg )
updateHelper { apiUrl } msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GotGlobalFeedArticlesResponse result ->
            case result of
                Ok { articles, totalArticles } ->
                    let
                        globalFeed =
                            setGlobalFeedPager
                                (Pager.setTotalPages totalArticles model.globalFeed.pager)
                                model.globalFeed
                    in
                    ( { model
                        | remoteDataArticles = RemoteData.Success articles
                        , globalFeed = globalFeed
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | remoteDataArticles = RemoteData.Failure () }
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
            ( if RemoteData.isLoading model.remoteDataArticles then
                model

              else
                { model | activeTab = tab }
            , Cmd.none
            )

        ToggledFavourite slug isFavourite ->
            ( model, Cmd.none )

        ClickedGlobalFeedPagination newPageNumber ->
            let
                globalFeed =
                    setGlobalFeedCurrentPageNumber newPageNumber model.globalFeed
            in
            ( { model
                | remoteDataArticles = RemoteData.Loading
                , globalFeed = globalFeed
              }
            , getGlobalFeedArticles apiUrl globalFeed
            )

        ClickedTag tag ->
            ( { model
                | remoteDataArticles = RemoteData.Success []
                , tag = tag
                , activeTab = FeedTabs.Tag tag

                --
                -- FIXME: Maybe we just need 1 feed data structure to hold on to everything.
                --
                , globalFeed = initGlobalFeed
              }
              --
              -- TODO: Get articles by tag, getTagFeedArticles apiUrl tagFeed.
              --
            , Cmd.none
            )


setGlobalFeedPager : Pager -> GlobalFeed -> GlobalFeed
setGlobalFeedPager pager globalFeed =
    { globalFeed | pager = pager }


setGlobalFeedCurrentPageNumber : Int -> GlobalFeed -> GlobalFeed
setGlobalFeedCurrentPageNumber pageNumber globalFeed =
    { globalFeed | currentPageNumber = pageNumber }



-- VIEW


type alias ViewOptions msg =
    { zone : Time.Zone
    , onChange : Msg -> msg
    }


view : ViewOptions msg -> Model -> H.Html msg
view { zone, onChange } model =
    let
        viewFeedTabs =
            [ FeedTabs.view
                { hasPersonal = model.hasPersonal
                , tag = model.tag
                , activeTab = model.activeTab
                , isDisabled = RemoteData.isLoading model.remoteDataArticles
                , onSwitch = SwitchedFeedTabs
                }
            ]

        viewArticlePreviews =
            case model.remoteDataArticles of
                RemoteData.Success articles ->
                    List.map (viewArticlePreview zone) articles

                _ ->
                    []

        viewPagination =
            [ Pagination.view <|
                case model.activeTab of
                    FeedTabs.Global ->
                        { totalPages =
                            model.globalFeed.pager
                                |> Pager.toTotalPages
                                |> Total.toInt
                        , currentPageNumber = model.globalFeed.currentPageNumber
                        , onClick = ClickedGlobalFeedPagination
                        }

                    _ ->
                        { totalPages = 0
                        , currentPageNumber = 1
                        , onClick = always NoOp
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
                            , activeTag =
                                case model.activeTab of
                                    FeedTabs.Tag tag ->
                                        tag

                                    _ ->
                                        ""
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
    ArticlePreview.view
        { name = Username.toString author.username
        , imageUrl = author.imageUrl
        , date = Timestamp.toString zone createdAt
        , totalFavourites = Total.toInt totalFavourites
        , isFavourite = isFavourite
        , slug = Slug.toString slug
        , title = title
        , description = description
        , tags = List.map Tag.toString tags
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
