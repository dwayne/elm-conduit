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
import Data.Article exposing (Article)
import Data.Email as Email exposing (Email)
import Data.Password as Password exposing (Password)
import Data.Tag as Tag exposing (Tag)
import Data.Token exposing (Token)
import Data.User exposing (User)
import Data.Username as Username exposing (Username)
import Data.Validation as V
import Html as H
import Html.Attributes as HA
import Lib.NonEmptyString exposing (NonEmptyString)
import Lib.OrderedSet as OrderedSet exposing (OrderedSet)
import Lib.String as String
import Lib.Task as Task
import Lib.Validation as V
import Url exposing (Url)
import View.Editor as Editor
import View.Footer as Footer
import View.Navigation as Navigation



-- MODEL


type alias Model =
    { title : String
    , description : String
    , body : String
    , tag : String
    , tags : OrderedSet Tag
    , errorMessages : List String
    , isDisabled : Bool
    }


init : Model
init =
    { title = ""
    , description = ""
    , body = ""
    , tag = ""
    , tags = OrderedSet.empty
    , errorMessages = []
    , isDisabled = False
    }



-- UPDATE


type Msg
    = ChangedTitle String
    | ChangedDescription String
    | ChangedBody String
    | ChangedTag String
    | EnteredTag Tag
    | RemovedTag Tag
    | SubmittedForm
    | GotCreateArticleResponse (Result (Api.Error (List String)) Article)


type alias UpdateOptions msg =
    { apiUrl : String
    , token : Token
    , onCreate : Article -> msg
    , onChange : Msg -> msg
    }


update : UpdateOptions msg -> Msg -> Model -> ( Model, Cmd msg )
update options msg model =
    case msg of
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

        SubmittedForm ->
            validate model
                |> V.withValidation
                    { onSuccess =
                        \{ title, description, body, tags } ->
                            ( { model | errorMessages = [], isDisabled = True }
                            , CreateArticle.createArticle
                                options.apiUrl
                                { token = options.token
                                , title = title
                                , description = description
                                , body = body
                                , tags = tags
                                , onResponse = GotCreateArticleResponse
                                }
                                |> Cmd.map options.onChange
                            )
                    , onFailure =
                        \errorMessages ->
                            ( { model | errorMessages = errorMessages }
                            , Cmd.none
                            )
                    }

        GotCreateArticleResponse result ->
            case result of
                Ok article ->
                    ( init
                    , Task.dispatch (options.onCreate article)
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
view { user, onChange } { title, description, body, tag, tags, errorMessages, isDisabled } =
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
                    [ Editor.view
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
                            , onSubmit = SubmittedForm
                            }
                        }
                    ]
                ]
            ]
        , Footer.view
        ]
        |> H.map onChange
