module Page.Register exposing (Model, Msg, ViewOptions, init, update, view)

import Api
import Api.Register as Register
import Data.Email as Email exposing (Email)
import Data.Password as Password exposing (Password)
import Data.User exposing (User)
import Data.Username as Username exposing (Username)
import Html as H
import Html.Attributes as HA
import Lib.String as String
import Lib.Task as Task
import Lib.Validation as Validation exposing (Validation)
import View.Footer as Footer
import View.Navigation as Navigation
import View.Register as Register
import View.RegisterForm as RegisterForm



-- MODEL


type alias Model =
    { username : String
    , email : String
    , password : String
    , errorMessages : List String
    , isDisabled : Bool
    }


init : Model
init =
    { username = ""
    , email = ""
    , password = ""
    , errorMessages = []
    , isDisabled = False
    }



-- UPDATE


type alias UpdateOptions msg =
    { apiUrl : String
    , onRegistered : User -> msg
    , onChange : Msg -> msg
    }


type Msg
    = ChangedUsername String
    | ChangedEmail String
    | ChangedPassword String
    | SubmittedForm
    | GotRegisterResponse (Result (Api.Error (List String)) User)


update : UpdateOptions msg -> Msg -> Model -> ( Model, Cmd msg )
update options msg model =
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
            case validate model of
                Validation.Success { username, email, password } ->
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

                Validation.Failure errorMessages ->
                    ( { model | errorMessages = errorMessages }
                    , Cmd.none
                    )

        GotRegisterResponse result ->
            case result of
                Ok user ->
                    ( init
                    , Task.dispatch (options.onRegistered user)
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
    { username : Username
    , email : Email
    , password : Password
    }


validate : Model -> Validation ValidatedFields
validate { username, email, password } =
    Validation.map ValidatedFields (validateUsername username)
        |> Validation.ap (validateEmail email)
        |> Validation.ap (validatePassword password)


validateUsername : String -> Validation Username
validateUsername rawUsername =
    case Username.fromString rawUsername of
        Just username ->
            Validation.Success username

        Nothing ->
            Validation.Failure [ "username can't be blank" ]


validateEmail : String -> Validation Email
validateEmail rawEmail =
    case Email.fromString rawEmail of
        Just email ->
            Validation.Success email

        Nothing ->
            Validation.Failure [ "email can't be blank" ]


validatePassword : String -> Validation Password
validatePassword rawPassword =
    case Password.fromString rawPassword of
        Ok password ->
            Validation.Success password

        Err Password.Blank ->
            Validation.Failure [ "password can't be blank" ]

        Err (Password.TooShort expectedLength) ->
            [ "password must be at least "
            , String.fromInt expectedLength
            , " "
            , String.pluralize
                expectedLength
                { singular = "character"
                , plural = "characters"
                }
            , " long"
            ]
                |> String.concat
                |> List.singleton
                |> Validation.Failure



-- VIEW


type alias ViewOptions msg =
    { onChange : Msg -> msg
    }


view : ViewOptions msg -> Model -> H.Html msg
view { onChange } { username, email, password, errorMessages, isDisabled } =
    H.div []
        [ Navigation.view { role = Navigation.register }
        , H.div
            [ HA.class "auth-page" ]
            [ H.div
                [ HA.class "container page" ]
                [ H.div
                    [ HA.class "row" ]
                    [ Register.view
                        { classNames = "col-md-6 offset-md-3 col-xs-12"
                        , errorMessages = errorMessages
                        , form =
                            { username = username
                            , email = email
                            , password = password
                            , isDisabled = isDisabled
                            , onInputUsername = ChangedUsername
                            , onInputEmail = ChangedEmail
                            , onInputPassword = ChangedPassword
                            , onSubmit = SubmittedForm
                            }
                        }
                    ]
                ]
            ]
        , Footer.view
        ]
        |> H.map onChange
