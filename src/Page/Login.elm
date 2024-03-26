module Page.Login exposing (Model, Msg, UpdateOptions, ViewOptions, init, update, view)

import Api
import Api.Login as Login
import Data.Email as Email exposing (Email)
import Data.Password as Password exposing (Password)
import Data.User exposing (User)
import Data.Validation as V
import Html as H
import Html.Attributes as HA
import Lib.Task as Task
import Lib.Validation as V
import Url exposing (Url)
import View.DefaultLayout as DefaultLayout
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


view : ViewOptions msg -> Model -> H.Html msg
view { onChange } =
    viewHelper >> H.map onChange


viewHelper : Model -> H.Html Msg
viewHelper { email, password, errorMessages, isDisabled } =
    DefaultLayout.view
        { role = Navigation.login }
        [ H.div
            [ HA.class "auth-page" ]
            [ H.div
                [ HA.class "container page" ]
                [ H.div
                    [ HA.class "row" ]
                    [ Login.view
                        { classNames = "col-md-6 offset-md-3 col-xs-12"
                        , form =
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
            ]
        ]
