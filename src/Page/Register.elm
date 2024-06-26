module Page.Register exposing (InitOptions, Model, Msg, UpdateOptions, ViewOptions, init, update, view)

import Api
import Api.Register as Register
import Browser as B
import Data.Email exposing (Email)
import Data.Password exposing (Password)
import Data.User exposing (User)
import Data.Username exposing (Username)
import Data.Validation as V
import Html as H
import Lib.Browser.Dom as BD
import Lib.Task as Task
import Lib.Validation as V
import Url exposing (Url)
import View.Column as Column
import View.Layout as Layout
import View.Navigation as Navigation
import View.Register as Register



-- MODEL


type alias Model =
    { username : String
    , email : String
    , password : String
    , errorMessages : List String
    , isDisabled : Bool
    }


type alias InitOptions msg =
    { onChange : Msg -> msg
    }


init : InitOptions msg -> ( Model, Cmd msg )
init { onChange } =
    ( initModel
    , BD.focus "username" FocusedUsername
        |> Cmd.map onChange
    )


initModel : Model
initModel =
    { username = ""
    , email = ""
    , password = ""
    , errorMessages = []
    , isDisabled = False
    }



-- UPDATE


type alias UpdateOptions msg =
    { apiUrl : Url
    , onRegistered : User -> msg
    , onChange : Msg -> msg
    }


type Msg
    = FocusedUsername
    | ChangedUsername String
    | ChangedEmail String
    | ChangedPassword String
    | SubmittedForm
    | GotRegisterResponse (Result (Api.Error (List String)) User)


update : UpdateOptions msg -> Msg -> Model -> ( Model, Cmd msg )
update options msg model =
    case msg of
        FocusedUsername ->
            ( model, Cmd.none )

        ChangedUsername username ->
            ( { model | username = username }
            , Cmd.none
            )

        ChangedEmail email ->
            ( { model | email = email }
            , Cmd.none
            )

        ChangedPassword password ->
            ( { model | password = password }
            , Cmd.none
            )

        SubmittedForm ->
            validate model
                |> V.withValidation
                    { onSuccess =
                        \{ username, email, password } ->
                            ( { model | errorMessages = [], isDisabled = True }
                            , Register.register
                                options.apiUrl
                                { username = username
                                , email = email
                                , password = password
                                , onResponse = GotRegisterResponse
                                }
                                |> Cmd.map options.onChange
                            )
                    , onFailure =
                        \errorMessages ->
                            ( { model | errorMessages = errorMessages }
                            , Cmd.none
                            )
                    }

        GotRegisterResponse result ->
            Api.handleFormResponse
                (\user ->
                    ( initModel
                    , Task.dispatch (options.onRegistered user)
                    )
                )
                model
                result


type alias ValidatedFields =
    { username : Username
    , email : Email
    , password : Password
    }


validate : Model -> V.Validation ValidatedFields
validate { username, email, password } =
    V.succeed ValidatedFields
        |> V.apply (V.username username)
        |> V.apply (V.email email)
        |> V.apply (V.password password)



-- VIEW


type alias ViewOptions msg =
    { onChange : Msg -> msg
    }


view : ViewOptions msg -> Model -> B.Document msg
view { onChange } { username, email, password, errorMessages, isDisabled } =
    { title = "Register"
    , body =
        [ Layout.view
            { name = "auth"
            , role = Navigation.register
            , maybeHeader = Nothing
            }
            [ Column.viewSingle Column.ExtraSmall
                [ Register.view
                    { form =
                        { username = username
                        , email = email
                        , password = password
                        , isDisabled = isDisabled
                        , onInputUsername = ChangedUsername
                        , onInputEmail = ChangedEmail
                        , onInputPassword = ChangedPassword
                        , onSubmit = SubmittedForm
                        }
                    , errorMessages = errorMessages
                    }
                ]
            ]
            |> H.map onChange
        ]
    }
