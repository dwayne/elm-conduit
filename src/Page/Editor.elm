module Page.Editor exposing
    ( Model
    , Msg
    , UpdateOptions
    , ViewOptions
    , init
    , update
    , view
    )

import Api
import Api.CreateArticle as CreateArticle
import Api.GetArticle as GetArticle
import Api.UpdateArticle as UpdateArticle
import Data.Article exposing (Article)
import Data.Email as Email exposing (Email)
import Data.Password as Password exposing (Password)
import Data.Slug exposing (Slug)
import Data.Tag as Tag exposing (Tag)
import Data.Token exposing (Token)
import Data.User exposing (User)
import Data.Username as Username exposing (Username)
import Data.Validation as V
import Html as H
import Html.Attributes as HA
import Lib.NonEmptyString exposing (NonEmptyString)
import Lib.OrderedSet as OrderedSet exposing (OrderedSet)
import Lib.RemoteData as RemoteData exposing (RemoteData)
import Lib.String as String
import Lib.Task as Task
import Lib.Validation as V
import Url exposing (Url)
import View.Editor as Editor
import View.Footer as Footer
import View.Navigation as Navigation



-- MODEL


type alias Model =
    { action : Action
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
    | Edit
        { slug : Slug
        , remoteData : RemoteData () ()
        }


type alias InitOptions msg =
    { apiUrl : String
    , token : Token
    , maybeSlug : Maybe Slug
    , onChange : Msg -> msg
    }


init : InitOptions msg -> ( Model, Cmd msg )
init { apiUrl, token, maybeSlug, onChange } =
    case maybeSlug of
        Nothing ->
            ( { action = Create
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
            ( { action =
                    Edit
                        { slug = slug
                        , remoteData = RemoteData.Loading
                        }
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
    { apiUrl : String
    , token : Token
    , onPublish : Article -> msg
    , onChange : Msg -> msg
    }


update : UpdateOptions msg -> Msg -> Model -> ( Model, Cmd msg )
update options msg model =
    case msg of
        GotGetArticleResponse result ->
            --
            -- TODO: Simplify.
            --
            case model.action of
                Edit editModel ->
                    case editModel.remoteData of
                        RemoteData.Loading ->
                            case result of
                                Ok article ->
                                    let
                                        newEditModel =
                                            { editModel | remoteData = RemoteData.Success () }
                                    in
                                    ( { model
                                        | action = Edit newEditModel
                                        , title = article.title
                                        , description = article.description
                                        , body = article.body
                                        , tags = OrderedSet.fromList article.tags
                                      }
                                    , Cmd.none
                                    )

                                Err _ ->
                                    let
                                        newEditModel =
                                            { editModel | remoteData = RemoteData.Failure () }
                                    in
                                    ( { model | action = Edit newEditModel }
                                    , Cmd.none
                                    )

                        _ ->
                            ( model, Cmd.none )

                Create ->
                    ( model, Cmd.none )

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
                        \{ title, description, body, tags } ->
                            ( { model | errorMessages = [], isDisabled = True }
                            , let
                                cmd =
                                    case maybeSlug of
                                        Nothing ->
                                            CreateArticle.createArticle
                                                options.apiUrl
                                                { token = options.token
                                                , title = title
                                                , description = description
                                                , body = body
                                                , tags = tags
                                                , onResponse = GotPublishArticleResponse
                                                }

                                        Just slug ->
                                            UpdateArticle.updateArticle
                                                options.apiUrl
                                                { token = options.token
                                                , slug = slug
                                                , title = title
                                                , description = description
                                                , body = body
                                                , tags = tags
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
            case result of
                Ok article ->
                    --
                    -- TODO: Add a resetModel function.
                    --
                    ( { model
                        | title = ""
                        , description = ""
                        , body = ""
                        , tag = ""
                        , tags = OrderedSet.empty
                        , errorMessages = []
                        , isDisabled = False
                      }
                    , Task.dispatch (options.onPublish article)
                    )

                Err err ->
                    let
                        newModel =
                            { model | isDisabled = False }
                    in
                    case err of
                        Api.UserError errorMessages ->
                            ( { newModel | errorMessages = errorMessages }
                            , Cmd.none
                            )

                        _ ->
                            ( { newModel | errorMessages = [ "An unexpected error occurred" ] }
                            , Cmd.none
                            )


type alias ValidatedFields =
    { title : NonEmptyString
    , description : NonEmptyString
    , body : NonEmptyString
    , tags : List Tag
    }


validate : Model -> V.Validation ValidatedFields
validate { title, description, body, tags } =
    V.succeed ValidatedFields
        |> V.apply (V.nonEmptyString "title" title)
        |> V.apply (V.nonEmptyString "description" description)
        |> V.apply (V.nonEmptyString "body" body)
        |> V.apply (V.tags tags)



-- VIEW


type alias ViewOptions msg =
    { user : User
    , onChange : Msg -> msg
    }


view : ViewOptions msg -> Model -> H.Html msg
view { user, onChange } { action, title, description, body, tag, tags, errorMessages, isDisabled } =
    H.div []
        [ Navigation.view
            { role =
                Navigation.newArticle
                    { username = user.username
                    , imageUrl = user.imageUrl
                    }
            }
        , H.div
            [ HA.class "editor-page" ]
            [ H.div
                [ HA.class "container page" ]
                [ H.div
                    [ HA.class "row" ]
                    [ withAction
                        { onLoading = H.text ""
                        , onSuccess =
                            \maybeSlug ->
                                Editor.view
                                    { classNames = "col-md-10 offset-md-1 col-xs-12"
                                    , errorMessages = errorMessages
                                    , form =
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
                                    }
                        , onFailure = H.text "Sorry, but we are unable to load the article."
                        }
                        action
                    ]
                ]
            ]
        , Footer.view
        ]
        |> H.map onChange


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

        Edit { slug, remoteData } ->
            --
            -- TODO: Use the remoteDataSlug idea instead.
            --
            case remoteData of
                RemoteData.Loading ->
                    onLoading

                RemoteData.Success () ->
                    onSuccess (Just slug)

                RemoteData.Failure () ->
                    onFailure
