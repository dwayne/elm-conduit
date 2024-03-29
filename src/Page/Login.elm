module Page.Login exposing (Model, Msg, UpdateOptions, ViewOptions, init, update, view)

import Api
import Api.Login as Login
import Browser as B
import Data.Email exposing (Email)
import Data.Password exposing (Password)
import Data.User exposing (User)
import Data.Validation as V
import Html as H
import Lib.Task as Task
import Lib.Validation as V
import Url exposing (Url)
import View.Column as Column
import View.Layout as Layout
import View.Login as Login
import View.Navigation as Navigation



-- MODEL


type alias Model =
    { email : String
    , password : String
    , errorMessages : List String
    , isDisabled : Bool
    }


init : Model
init =
    { email = ""
    , password = ""
    , errorMessages = []
    , isDisabled = False
    }



-- UPDATE


type alias UpdateOptions msg =
    { apiUrl : Url
    , onLoggedIn : User -> msg
    , onChange : Msg -> msg
    }


type Msg
    = ChangedEmail String
    | ChangedPassword String
    | SubmittedForm
    | GotLoginResponse (Result (Api.Error (List String)) User)


update : UpdateOptions msg -> Msg -> Model -> ( Model, Cmd msg )
update options msg model =
    case msg of
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
                        \{ email, password } ->
                            ( { model | errorMessages = [], isDisabled = True }
                            , Login.login
                                options.apiUrl
                                { email = email
                                , password = password
                                , onResponse = GotLoginResponse
                                }
                                |> Cmd.map options.onChange
                            )
                    , onFailure =
                        \errorMessages ->
                            ( { model | errorMessages = errorMessages }
                            , Cmd.none
                            )
                    }

        GotLoginResponse result ->
            Api.handleFormResponse
                (\user ->
                    ( init
                    , Task.dispatch (options.onLoggedIn user)
                    )
                )
                model
                result


type alias ValidatedFields =
    { email : Email
    , password : Password
    }


validate : Model -> V.Validation ValidatedFields
validate { email, password } =
    V.succeed ValidatedFields
        |> V.apply (V.email email)
        |> V.apply (V.password password)



-- VIEW


type alias ViewOptions msg =
    { onChange : Msg -> msg
    }


view : ViewOptions msg -> Model -> B.Document msg
view { onChange } { email, password, errorMessages, isDisabled } =
    { title = "Login"
    , body =
        [ Layout.view
            { name = "auth"
            , role = Navigation.login
            , maybeHeader = Nothing
            }
            [ Column.viewSingle Column.ExtraSmall
                [ Login.view
                    { form =
                        { email = email
                        , password = password
                        , isDisabled = isDisabled
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
