module Page.Article exposing (InitOptions, Model, Msg, UpdateOptions, ViewOptions, init, update, view)

import Api
import Api.GetArticle as GetArticle
import Data.Article exposing (Article)
import Data.Slug exposing (Slug)
import Data.User exposing (User)
import Html as H
import Html.Attributes as HA
import Lib.Either as Either exposing (Either)
import Lib.RemoteData as RemoteData exposing (RemoteData)
import Time
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
    , eitherSlugOrArticle : Either Slug Article
    , onChange : Msg -> msg
    }


init : InitOptions msg -> ( Model, Cmd msg )
init { apiUrl, eitherSlugOrArticle, onChange } =
    let
        ( remoteDataArticle, cmd ) =
            case eitherSlugOrArticle of
                Either.Left slug ->
                    ( RemoteData.Loading
                    , GetArticle.getArticle
                        apiUrl
                        { slug = slug
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
    , user : User
    , onChange : Msg -> msg
    }


view : ViewOptions msg -> Model -> H.Html msg
view { zone, user, onChange } { remoteDataArticle, isDisabled } =
    H.div []
        [ Navigation.view
            { role =
                Navigation.user
                    { username = user.username
                    , imageUrl = user.imageUrl
                    }
            }
        , H.div [ HA.class "article-page" ] <|
            case remoteDataArticle of
                RemoteData.Loading ->
                    [ H.text "Loading..." ]

                RemoteData.Success article ->
                    [ ArticleHeader.view
                        { title = article.title
                        , meta =
                            { username = user.username
                            , imageUrl = user.imageUrl
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
                                    ArticleMeta.Guest
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
                        }
                    ]

                RemoteData.Failure _ ->
                    [ H.text "Unable to load the article." ]
        ]
        |> H.map onChange
