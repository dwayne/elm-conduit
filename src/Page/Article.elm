module Page.Article exposing (InitOptions, Model, Msg, UpdateOptions, ViewOptions, init, update, view)

import Api
import Api.DeleteArticle as DeleteArticle
import Api.GetArticle as GetArticle
import Api.ToggleFavourite as ToggleFavourite
import Api.ToggleFollow as ToggleFollow
import Data.Article exposing (Article)
import Data.Route as Route
import Data.Slug exposing (Slug)
import Data.Token exposing (Token)
import Data.User exposing (User)
import Data.Username exposing (Username)
import Data.Viewer as Viewer exposing (Viewer)
import Html as H
import Html.Attributes as HA
import Lib.Either as Either exposing (Either)
import Lib.RemoteData as RemoteData exposing (RemoteData)
import Lib.Task as Task
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
    | ToggledFollow Token Username Bool
    | GotToggleFollowResponse (Result (Api.Error ()) Bool)
    | ToggledFavourite Token Slug Bool
    | GotToggleFavouriteResponse (Result (Api.Error ()) ToggleFavourite.TotalFavourites)
    | ClickedDeleteArticle Token Slug
    | GotDeleteArticleResponse (Result (Api.Error ()) ())


type alias UpdateOptions msg =
    { apiUrl : String
    , onDelete : msg
    , onChange : Msg -> msg
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
            case result of
                Ok isFollowing ->
                    ( { newModel
                        | remoteDataArticle =
                            RemoteData.map
                                (\article ->
                                    let
                                        author =
                                            article.author

                                        newAuthor =
                                            { author | isFollowing = isFollowing }
                                    in
                                    { article | author = newAuthor }
                                )
                                newModel.remoteDataArticle
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( newModel
                    , Cmd.none
                    )

        ToggledFavourite token slug isFavourite ->
            ( { model | isDisabled = True }
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
                    { model | isDisabled = False }
            in
            case result of
                Ok { isFavourite, totalFavourites } ->
                    ( { newModel
                        | remoteDataArticle =
                            RemoteData.map
                                (\article ->
                                    { article
                                        | isFavourite = isFavourite
                                        , totalFavourites = totalFavourites
                                    }
                                )
                                newModel.remoteDataArticle
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( newModel
                    , Cmd.none
                    )

        ClickedDeleteArticle token slug ->
            ( { model | isDisabled = True }
            , DeleteArticle.deleteArticle
                options.apiUrl
                { token = token
                , slug = slug
                , onResponse = GotDeleteArticleResponse
                }
                |> Cmd.map options.onChange
            )

        GotDeleteArticleResponse result ->
            case result of
                Ok () ->
                    ( model
                    , Task.dispatch options.onDelete
                    )

                Err _ ->
                    ( { model | isDisabled = False }
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
                                            , onDelete = ClickedDeleteArticle user.token
                                            }

                                    else
                                        ArticleMeta.User
                                            { isDisabled = isDisabled
                                            , isFollowing = article.author.isFollowing
                                            , onFollow = toToggledFollowMsg True
                                            , onUnfollow = toToggledFollowMsg False
                                            , isFavourite = article.isFavourite
                                            , totalFavourites = article.totalFavourites
                                            , onFavourite = toToggledFavouriteMsg True
                                            , onUnfavourite = toToggledFavouriteMsg False
                                            }
                                }

                            toToggledFollowMsg =
                                ToggledFollow user.token article.author.username

                            toToggledFavouriteMsg =
                                ToggledFavourite user.token article.slug
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
