module Page.Register exposing (Model, Msg, ViewOptions, init, update, view)

import Html as H
import Html.Attributes as HA
import View.Footer as Footer
import View.Navigation as Navigation
import View.Register as Register
import View.RegisterForm as RegisterForm



-- MODEL


type alias Model =
    { username : String
    , email : String
    , password : String
    }


init : Model
init =
    { username = ""
    , email = ""
    , password = ""
    }



-- UPDATE


type Msg
    = ChangedUsername String
    | ChangedEmail String
    | ChangedPassword String
    | SubmittedForm


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
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
            ( model, Cmd.none )



-- VIEW


type alias ViewOptions msg =
    { onChange : Msg -> msg
    }


view : ViewOptions msg -> Model -> H.Html msg
view { onChange } { username, email, password } =
    let
        errorMessages =
            []
    in
    H.div []
        [ Navigation.view { role = Navigation.register }
        , H.div
            [ HA.class "auth-page" ]
            [ H.div
                [ HA.class "container page" ]
                [ H.div
                    [ HA.class "row" ]
                    [ Register.view
                        "col-md-6 offset-md-3 col-xs-12"
                        { form =
                            { username = username
                            , email = email
                            , password = password
                            , status = RegisterForm.Invalid
                            , onInputUsername = ChangedUsername
                            , onInputEmail = ChangedEmail
                            , onInputPassword = ChangedPassword
                            , onSubmit = SubmittedForm
                            }
                        , errorMessages = errorMessages
                        }
                    ]
                ]
            ]
        , Footer.view
        ]
        |> H.map onChange
