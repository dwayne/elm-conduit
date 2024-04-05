module Page.Editor exposing (InitOptions, Model, Msg, UpdateOptions, ViewOptions, init, update, view)

import Api
import Api.CreateArticle as CreateArticle
import Api.GetArticle as GetArticle
import Api.UpdateArticle as UpdateArticle
import Browser as B
import Data.Article as Article exposing (Article)
import Data.Slug exposing (Slug)
import Data.Tag exposing (Tag)
import Data.Token exposing (Token)
import Data.User exposing (User)
import Data.Validation as V
import Html as H
import Lib.OrderedSet as OrderedSet exposing (OrderedSet)
import Lib.RemoteData as RemoteData exposing (RemoteData)
import Lib.Task as Task
import Lib.Validation as V
import Url exposing (Url)
import View.Column as Column
import View.Editor as Editor
import View.Layout as Layout
import View.Navigation as Navigation



-- MODEL


type alias Model =
    { action : Action
    , previousTitle : String
    , title : String
    , description : String
    , body : String
    , tag : String
    , tags : OrderedSet Tag
    , errorMessages : List String
    , isDisabled : Bool
    }


type Action
    = Create
    | Edit (RemoteData () Slug)


type alias InitOptions msg =
    { apiUrl : Url
    , token : Token
    , maybeSlug : Maybe Slug
    , onChange : Msg -> msg
    }


init : InitOptions msg -> ( Model, Cmd msg )
init { apiUrl, token, maybeSlug, onChange } =
    case maybeSlug of
        Nothing ->
            ( { action = Create
              , previousTitle = ""
              , title = ""
              , description = ""
              , body = ""
              , tag = ""
              , tags = OrderedSet.empty
              , errorMessages = []
              , isDisabled = False
              }
            , Cmd.none
            )

        Just slug ->
            ( { action = Edit RemoteData.Loading
              , previousTitle = ""
              , title = ""
              , description = ""
              , body = ""
              , tag = ""
              , tags = OrderedSet.empty
              , errorMessages = []
              , isDisabled = False
              }
            , GetArticle.getArticle
                apiUrl
                { maybeToken = Just token
                , slug = slug
                , onResponse = GotGetArticleResponse
                }
                |> Cmd.map onChange
            )


resetModel : String -> Model -> Model
resetModel previousTitle model =
    { model
        | previousTitle = previousTitle
        , title = ""
        , description = ""
        , body = ""
        , tag = ""
        , tags = OrderedSet.empty
        , errorMessages = []
        , isDisabled = False
    }



-- UPDATE


type Msg
    = GotGetArticleResponse (Result (Api.Error ()) Article)
    | ChangedTitle String
    | ChangedDescription String
    | ChangedBody String
    | ChangedTag String
    | EnteredTag Tag
    | RemovedTag Tag
    | SubmittedForm (Maybe Slug)
    | GotPublishArticleResponse (Result (Api.Error (List String)) Article)


type alias UpdateOptions msg =
    { apiUrl : Url
    , token : Token
    , onPublish : Article -> msg
    , onChange : Msg -> msg
    }


update : UpdateOptions msg -> Msg -> Model -> ( Model, Cmd msg )
update options msg model =
    case msg of
        GotGetArticleResponse result ->
            ( case model.action of
                Edit RemoteData.Loading ->
                    case result of
                        Ok article ->
                            { model
                                | action = Edit <| RemoteData.Success article.slug
                                , previousTitle = article.title
                                , title = article.title
                                , description = article.description
                                , body = article.body
                                , tags = OrderedSet.fromList article.tags
                            }

                        Err _ ->
                            { model | action = Edit <| RemoteData.Failure () }

                _ ->
                    model
            , Cmd.none
            )

        ChangedTitle title ->
            ( { model | title = title }
            , Cmd.none
            )

        ChangedDescription description ->
            ( { model | description = description }
            , Cmd.none
            )

        ChangedBody body ->
            ( { model | body = body }
            , Cmd.none
            )

        ChangedTag tag ->
            ( { model | tag = tag }
            , Cmd.none
            )

        EnteredTag tag ->
            ( { model | tag = "", tags = OrderedSet.add tag model.tags }
            , Cmd.none
            )

        RemovedTag tag ->
            ( { model | tags = OrderedSet.remove tag model.tags }
            , Cmd.none
            )

        SubmittedForm maybeSlug ->
            validate model
                |> V.withValidation
                    { onSuccess =
                        \articleFields ->
                            ( { model | errorMessages = [], isDisabled = True }
                            , let
                                cmd =
                                    case maybeSlug of
                                        Nothing ->
                                            CreateArticle.createArticle
                                                options.apiUrl
                                                { token = options.token
                                                , articleFields = articleFields
                                                , onResponse = GotPublishArticleResponse
                                                }

                                        Just slug ->
                                            UpdateArticle.updateArticle
                                                options.apiUrl
                                                { token = options.token
                                                , slug = slug
                                                , articleFields = articleFields
                                                , onResponse = GotPublishArticleResponse
                                                }
                              in
                              Cmd.map options.onChange cmd
                            )
                    , onFailure =
                        \errorMessages ->
                            ( { model | errorMessages = errorMessages }
                            , Cmd.none
                            )
                    }

        GotPublishArticleResponse result ->
            Api.handleFormResponse
                (\article ->
                    ( resetModel article.title model
                    , Task.dispatch (options.onPublish article)
                    )
                )
                model
                result


validate : Model -> V.Validation Article.Fields
validate { title, description, body, tags } =
    V.succeed Article.Fields
        |> V.apply (V.nonEmptyString "title" title)
        |> V.apply (V.nonEmptyString "description" description)
        |> V.apply (V.nonEmptyString "body" body)
        |> V.apply (V.tags tags)



-- VIEW


type alias ViewOptions msg =
    { user : User
    , onLogout : msg
    , onChange : Msg -> msg
    }


view : ViewOptions msg -> Model -> B.Document msg
view { user, onLogout, onChange } { action, previousTitle, title, description, body, tag, tags, errorMessages, isDisabled } =
    let
        userDetails =
            { username = user.username
            , imageUrl = user.imageUrl
            , onLogout = onLogout
            }

        ( pageTitle, role ) =
            case action of
                Create ->
                    ( "New Article"
                    , Navigation.newArticle userDetails
                    )

                Edit _ ->
                    ( if String.isEmpty previousTitle then
                        "Edit Article"

                      else
                        "Edit \"" ++ previousTitle ++ "\""
                    , Navigation.user userDetails
                    )
    in
    { title = pageTitle
    , body =
        [ Layout.view
            { name = "editor"
            , role = role
            , maybeHeader = Nothing
            }
            [ withAction
                { onLoading = H.text "Loading..."
                , onSuccess =
                    \maybeSlug ->
                        Column.viewSingle Column.Medium
                            [ Editor.view
                                { form =
                                    { title = title
                                    , description = description
                                    , body = body
                                    , tag = tag
                                    , tags = tags
                                    , isDisabled = isDisabled
                                    , onInputTitle = ChangedTitle
                                    , onInputDescription = ChangedDescription
                                    , onInputBody = ChangedBody
                                    , onInputTag = ChangedTag
                                    , onEnterTag = EnteredTag
                                    , onRemoveTag = RemovedTag
                                    , onSubmit = SubmittedForm maybeSlug
                                    }
                                , errorMessages = errorMessages
                                }
                            ]
                            |> H.map onChange
                , onFailure = H.text "Unable to load the article."
                }
                action
            ]
        ]
    }


withAction :
    { onLoading : a
    , onSuccess : Maybe Slug -> a
    , onFailure : a
    }
    -> Action
    -> a
withAction { onLoading, onSuccess, onFailure } action =
    case action of
        Create ->
            onSuccess Nothing

        Edit remoteDataSlug ->
            case remoteDataSlug of
                RemoteData.Loading ->
                    onLoading

                RemoteData.Success slug ->
                    onSuccess (Just slug)

                RemoteData.Failure () ->
                    onFailure
