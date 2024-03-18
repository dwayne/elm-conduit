module Page.Article exposing (InitOptions, Model, Msg, UpdateOptions, ViewOptions, init, update, view)

import Api
import Api.CreateComment as CreateComment
import Api.DeleteArticle as DeleteArticle
import Api.DeleteComment as DeleteComment
import Api.GetArticle as GetArticle
import Api.GetComments as GetComments
import Api.ToggleFavourite as ToggleFavourite
import Api.ToggleFollow as ToggleFollow
import Data.Article exposing (Article)
import Data.Comment exposing (Comment)
import Data.Comments as Comments exposing (Comments)
import Data.Route as Route
import Data.Slug exposing (Slug)
import Data.Token exposing (Token)
import Data.User exposing (User)
import Data.Username exposing (Username)
import Data.Viewer as Viewer exposing (Viewer)
import Html as H
import Html.Attributes as HA
import Lib.Browser.Dom as BD
import Lib.Either as Either exposing (Either)
import Lib.NonEmptyString as NonEmptyString
import Lib.RemoteData as RemoteData exposing (RemoteData)
import Lib.Task as Task
import Time
import Url exposing (Url)
import View.ArticleContent as ArticleContent
import View.ArticleHeader as ArticleHeader
import View.ArticleMeta as ArticleMeta
import View.Comment as Comment
import View.CommentForm as CommentForm
import View.Navigation as Navigation



-- MODEL


type alias Model =
    { remoteDataArticle : RemoteData () Article
    , remoteDataComments : RemoteData () Comments
    , comment : String
    , isDisabled : Bool
    }


type alias InitOptions msg =
    { apiUrl : Url
    , viewer : Viewer
    , eitherSlugOrArticle : Either Slug Article
    , onChange : Msg -> msg
    }


init : InitOptions msg -> ( Model, Cmd msg )
init { apiUrl, viewer, eitherSlugOrArticle, onChange } =
    let
        maybeToken =
            Viewer.toToken viewer

        ( remoteDataArticle, cmd ) =
            case eitherSlugOrArticle of
                Either.Left slug ->
                    ( RemoteData.Loading
                    , Cmd.batch
                        [ GetArticle.getArticle
                            apiUrl
                            { maybeToken = maybeToken
                            , slug = slug
                            , onResponse = GotGetArticleResponse
                            }
                        , GetComments.getComments
                            apiUrl
                            { maybeToken = maybeToken
                            , slug = slug
                            , onResponse = GotGetCommentsResponse
                            }
                        ]
                    )

                Either.Right article ->
                    ( RemoteData.Success article
                    , GetComments.getComments
                        apiUrl
                        { maybeToken = maybeToken
                        , slug = article.slug
                        , onResponse = GotGetCommentsResponse
                        }
                    )
    in
    ( { remoteDataArticle = remoteDataArticle
      , remoteDataComments = RemoteData.Loading
      , comment = ""
      , isDisabled = False
      }
    , Cmd.map onChange cmd
    )



-- UPDATE


type Msg
    = GotGetArticleResponse (Result (Api.Error ()) Article)
    | GotGetCommentsResponse (Result (Api.Error ()) Comments)
    | ToggledFollow Token Username Bool
    | GotToggleFollowResponse (Result (Api.Error ()) Bool)
    | ToggledFavourite Token Slug Bool
    | GotToggleFavouriteResponse (Result (Api.Error ()) ToggleFavourite.TotalFavourites)
    | ClickedDeleteArticle Token Slug
    | GotDeleteArticleResponse (Result (Api.Error ()) ())
    | ChangedComment String
    | SubmittedComment Token Slug
    | GotCreateCommentResponse (Result (Api.Error ()) Comment)
    | FocusedCommentForm
    | ClickedDeleteComment Token Slug Int
    | GotDeleteCommentResponse (Result (Api.Error ()) Int)


type alias UpdateOptions msg =
    { apiUrl : Url
    , onDeleteArticle : msg
    , onChange : Msg -> msg
    }


update : UpdateOptions msg -> Msg -> Model -> ( Model, Cmd msg )
update options msg model =
    case msg of
        GotGetArticleResponse result ->
            ( { model
                | remoteDataArticle =
                    result
                        |> Result.map RemoteData.Success
                        |> Result.withDefault (RemoteData.Failure ())
              }
            , Cmd.none
            )

        GotGetCommentsResponse result ->
            ( { model
                | remoteDataComments =
                    result
                        |> Result.map RemoteData.Success
                        |> Result.withDefault (RemoteData.Failure ())
              }
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
                            | remoteDataArticle =
                                RemoteData.map (toggleFollowAuthor isFollowing) newModel.remoteDataArticle
                        }
                    )
                |> Result.withDefault newModel
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
            ( result
                |> Result.map
                    (\totalFavourites ->
                        { newModel
                            | remoteDataArticle =
                                RemoteData.map (toggleFavoriteArticle totalFavourites) newModel.remoteDataArticle
                        }
                    )
                |> Result.withDefault newModel
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
            ( { model | isDisabled = False }
            , result
                |> Result.map (always <| Task.dispatch options.onDeleteArticle)
                |> Result.withDefault Cmd.none
            )

        ChangedComment comment ->
            ( { model | comment = comment }
            , Cmd.none
            )

        SubmittedComment token slug ->
            case NonEmptyString.fromString model.comment of
                Just comment ->
                    ( { model | isDisabled = True }
                    , CreateComment.createComment
                        options.apiUrl
                        { token = token
                        , slug = slug
                        , comment = comment
                        , onResponse = GotCreateCommentResponse
                        }
                        |> Cmd.map options.onChange
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        GotCreateCommentResponse result ->
            let
                newModel =
                    { model | isDisabled = False }
            in
            case result of
                Ok comment ->
                    ( { newModel
                        | comment = ""
                        , remoteDataComments =
                            RemoteData.map (Comments.add comment) newModel.remoteDataComments
                      }
                    , BD.focus commentFormId FocusedCommentForm
                        |> Cmd.map options.onChange
                    )

                Err _ ->
                    ( newModel
                    , Cmd.none
                    )

        FocusedCommentForm ->
            ( model, Cmd.none )

        ClickedDeleteComment token slug id ->
            ( { model | isDisabled = True }
            , DeleteComment.deleteComment
                options.apiUrl
                { token = token
                , slug = slug
                , id = id
                , onResponse = GotDeleteCommentResponse
                }
                |> Cmd.map options.onChange
            )

        GotDeleteCommentResponse result ->
            let
                newModel =
                    { model | isDisabled = False }
            in
            ( result
                |> Result.map
                    (\id ->
                        { newModel
                            | remoteDataComments =
                                RemoteData.map (Comments.remove id) newModel.remoteDataComments
                        }
                    )
                |> Result.withDefault newModel
            , Cmd.none
            )



-- VIEW


type alias ViewOptions msg =
    { zone : Time.Zone
    , viewer : Viewer
    , onChange : Msg -> msg
    }


view : ViewOptions msg -> Model -> H.Html msg
view { zone, viewer, onChange } { remoteDataArticle, remoteDataComments, comment, isDisabled } =
    case viewer of
        Viewer.Guest ->
            viewArticleAsGuest
                { zone = zone
                , remoteDataArticle = remoteDataArticle
                }

        Viewer.User user ->
            viewArticleAsUser
                { zone = zone
                , user = user
                , remoteDataArticle = remoteDataArticle
                , remoteDataComments = remoteDataComments
                , comment = comment
                , isDisabled = isDisabled
                }
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


viewArticleAsUser :
    { zone : Time.Zone
    , user : User
    , remoteDataArticle : RemoteData () Article
    , remoteDataComments : RemoteData () Comments
    , comment : String
    , isDisabled : Bool
    }
    -> H.Html Msg
viewArticleAsUser { zone, user, remoteDataArticle, remoteDataComments, comment, isDisabled } =
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
                    , H.div
                        [ HA.class "row" ]
                        [ H.div
                            [ HA.class "col-xs-12 col-md-8 offset-md-2" ]
                            ([ CommentForm.view
                                { htmlId = commentFormId
                                , comment = comment
                                , imageUrl = user.imageUrl
                                , isDisabled = isDisabled
                                , onInputComment = ChangedComment
                                , onSubmit = SubmittedComment user.token article.slug
                                }
                             ]
                                ++ viewComments
                                    (List.map
                                        (viewComment
                                            { zone = zone
                                            , username = user.username
                                            , token = user.token
                                            , slug = article.slug
                                            , isDisabled = isDisabled
                                            }
                                        )
                                        << Comments.toList
                                    )
                                    remoteDataComments
                            )
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
                []

            RemoteData.Success article ->
                toHtml article

            RemoteData.Failure () ->
                [ H.div
                    [ HA.class "container page" ]
                    [ H.text "Unable to load the article." ]
                ]


viewComments : (Comments -> List (H.Html msg)) -> RemoteData () Comments -> List (H.Html msg)
viewComments toHtml remoteDataComments =
    case remoteDataComments of
        RemoteData.Loading ->
            []

        RemoteData.Success comments ->
            toHtml comments

        RemoteData.Failure () ->
            [ H.text "Unable to load comments." ]


viewComment :
    { zone : Time.Zone
    , username : Username
    , token : Token
    , slug : Slug
    , isDisabled : Bool
    }
    -> Comment
    -> H.Html Msg
viewComment { zone, username, token, slug, isDisabled } { id, createdAt, body, commenter } =
    Comment.view
        { body = body
        , username = commenter.username
        , imageUrl = commenter.imageUrl
        , zone = zone
        , createdAt = createdAt
        , maybeDelete =
            if username == commenter.username then
                Just
                    { isDisabled = isDisabled
                    , onDelete = ClickedDeleteComment token slug id
                    }

            else
                Nothing
        }



-- CONSTANTS


commentFormId : String
commentFormId =
    "comment-form"



-- HELPERS


toggleFollowAuthor : Bool -> Article -> Article
toggleFollowAuthor isFollowing article =
    let
        author =
            article.author

        newAuthor =
            { author | isFollowing = isFollowing }
    in
    { article | author = newAuthor }


toggleFavoriteArticle : ToggleFavourite.TotalFavourites -> Article -> Article
toggleFavoriteArticle { isFavourite, totalFavourites } article =
    { article
        | isFavourite = isFavourite
        , totalFavourites = totalFavourites
    }
