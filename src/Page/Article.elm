module Page.Article exposing (InitOptions, Model, Msg, UpdateOptions, ViewOptions, init, update, view)

import Api
import Api.GetArticle as GetArticle
import Data.Article exposing (Article)
import Data.Route as Route
import Data.Slug exposing (Slug)
import Data.User exposing (User)
import Data.Viewer as Viewer exposing (Viewer)
import Html as H
import Html.Attributes as HA
import Lib.Either as Either exposing (Either)
import Lib.RemoteData as RemoteData exposing (RemoteData)
import Time
import View.ArticleContent as ArticleContent
import View.ArticleHeader as ArticleHeader
import View.ArticleMeta as ArticleMeta
import View.Navigation as Navigation



-- MODEL


type alias Model =
    { remoteDataArticle : RemoteData () Article
    , isDisabled : Bool
    }


type alias InitOptions msg =
    { apiUrl : String
    , viewer : Viewer
    , eitherSlugOrArticle : Either Slug Article
    , onChange : Msg -> msg
    }


init : InitOptions msg -> ( Model, Cmd msg )
init { apiUrl, viewer, eitherSlugOrArticle, onChange } =
    let
        ( remoteDataArticle, cmd ) =
            case eitherSlugOrArticle of
                Either.Left slug ->
                    ( RemoteData.Loading
                    , GetArticle.getArticle
                        apiUrl
                        { maybeToken = Viewer.toToken viewer
                        , slug = slug
                        , onResponse = GotGetArticleResponse
                        }
                    )

                Either.Right article ->
                    ( RemoteData.Success article
                    , Cmd.none
                    )
    in
    ( { remoteDataArticle = remoteDataArticle
      , isDisabled = False
      }
    , Cmd.map onChange cmd
    )



-- UPDATE


type Msg
    = NoOp
    | GotGetArticleResponse (Result (Api.Error ()) Article)


type alias UpdateOptions msg =
    { onChange : Msg -> msg
    }


update : UpdateOptions msg -> Msg -> Model -> ( Model, Cmd msg )
update options msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GotGetArticleResponse result ->
            case result of
                Ok article ->
                    ( { model | remoteDataArticle = RemoteData.Success article }
                    , Cmd.none
                    )

                Err _ ->
                    --
                    -- TODO: Figure out what caused the error.
                    --
                    -- For e.g. Did we not find the article or was it a network failure?
                    --
                    ( { model | remoteDataArticle = RemoteData.Failure () }
                    , Cmd.none
                    )



-- VIEW


type alias ViewOptions msg =
    { zone : Time.Zone
    , viewer : Viewer
    , onChange : Msg -> msg
    }


view : ViewOptions msg -> Model -> H.Html msg
view { zone, viewer, onChange } { remoteDataArticle, isDisabled } =
    case viewer of
        Viewer.Guest ->
            viewArticleAsGuest
                { zone = zone
                , remoteDataArticle = remoteDataArticle
                }

        Viewer.User user ->
            H.div []
                [ Navigation.view
                    { role =
                        Navigation.user
                            { username = user.username
                            , imageUrl = user.imageUrl
                            }
                    }
                , viewArticle
                    (\article ->
                        let
                            articleMetaViewOptions =
                                { username = article.author.username
                                , imageUrl = article.author.imageUrl
                                , zone = zone
                                , createdAt = article.createdAt
                                , role =
                                    if user.username == article.author.username then
                                        ArticleMeta.Author
                                            { isDisabled = isDisabled
                                            , slug = article.slug
                                            , onDelete = always NoOp
                                            }

                                    else
                                        ArticleMeta.User
                                            { isDisabled = isDisabled
                                            , isFollowed = False
                                            , onFollow = NoOp
                                            , onUnfollow = NoOp
                                            , isFavourite = article.isFavourite
                                            , totalFavourites = article.totalFavourites
                                            , onFavourite = NoOp
                                            , onUnfavourite = NoOp
                                            }
                                }
                        in
                        [ ArticleHeader.view
                            { title = article.title
                            , meta = articleMetaViewOptions
                            }
                        , H.div
                            [ HA.class "container page" ]
                            [ ArticleContent.view
                                { description = article.description
                                , body = article.body
                                , tags = article.tags
                                }
                            , H.hr [] []
                            , H.div
                                [ HA.class "article-actions" ]
                                [ ArticleMeta.view articleMetaViewOptions
                                ]
                            ]
                        ]
                    )
                    remoteDataArticle
                ]
                |> H.map onChange


viewArticleAsGuest :
    { zone : Time.Zone
    , remoteDataArticle : RemoteData () Article
    }
    -> H.Html msg
viewArticleAsGuest { zone, remoteDataArticle } =
    H.div []
        [ Navigation.view
            { role = Navigation.guest
            }
        , viewArticle
            (\article ->
                [ ArticleHeader.view
                    { title = article.title
                    , meta =
                        { username = article.author.username
                        , imageUrl = article.author.imageUrl
                        , zone = zone
                        , createdAt = article.createdAt
                        , role = ArticleMeta.Guest
                        }
                    }
                , H.div
                    [ HA.class "container page" ]
                    [ ArticleContent.view
                        { description = article.description
                        , body = article.body
                        , tags = article.tags
                        }
                    , H.hr [] []
                    , H.div
                        [ HA.class "article-actions" ]
                        [ H.p []
                            [ H.a
                                [ HA.href <| Route.toString Route.Login ]
                                [ H.text "Sign in" ]
                            , H.text " or "
                            , H.a
                                [ HA.href <| Route.toString Route.Register ]
                                [ H.text "Sign up" ]
                            , H.text " to add comments on this article."
                            ]
                        ]
                    ]
                ]
            )
            remoteDataArticle
        ]


viewArticle : (Article -> List (H.Html msg)) -> RemoteData () Article -> H.Html msg
viewArticle toHtml remoteDataArticle =
    H.div [ HA.class "article-page" ] <|
        case remoteDataArticle of
            RemoteData.Loading ->
                viewLoading

            RemoteData.Success article ->
                toHtml article

            RemoteData.Failure _ ->
                viewFailure


viewLoading : List (H.Html msg)
viewLoading =
    [ H.text "" ]


viewFailure : List (H.Html msg)
viewFailure =
    [ H.div
        [ HA.class "container page" ]
        [ H.text "Sorry, but we are unable to load the article." ]
    ]
