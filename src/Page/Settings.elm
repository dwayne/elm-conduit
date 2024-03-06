module Page.Settings exposing
    ( Model
    , Msg
    , UpdateOptions
    , ViewOptions
    , init
    , update
    , view
    )

import Api
import Api.UpdateUser as UpdateUser
import Data.Email as Email exposing (Email)
import Data.Password as Password exposing (Password)
import Data.Token exposing (Token)
import Data.User exposing (User)
import Data.Username as Username exposing (Username)
import Html as H
import Html.Attributes as HA
import Lib.String as String
import Lib.Task as Task
import Lib.Validation as V
import Url exposing (Url)
import View.Footer as Footer
import View.Navigation as Navigation
import View.Settings as Settings



-- MODEL


type alias Model =
    { imageUrl : String
    , username : String
    , bio : String
    , email : String
    , password : String
    , isDisabled : Bool
    , errorMessages : List String
    }


type alias InitOptions =
    { imageUrl : Url
    , username : Username
    , bio : String
    , email : Email
    }


init : InitOptions -> Model
init { imageUrl, username, bio, email } =
    { imageUrl = Url.toString imageUrl
    , username = Username.toString username
    , bio = bio
    , email = Email.toString email
    , password = ""
    , isDisabled = False
    , errorMessages = []
    }



-- UPDATE


type alias UpdateOptions msg =
    { apiUrl : String
    , token : Token
    , onUpdatedUser : User -> msg
    , onChange : Msg -> msg
    }


type Msg
    = ChangedImageUrl String
    | ChangedUsername String
    | ChangedBio String
    | ChangedEmail String
    | ChangedPassword String
    | SubmittedForm
    | GotUpdateUserResponse (Result (Api.Error (List String)) User)


update : UpdateOptions msg -> Msg -> Model -> ( Model, Cmd msg )
update options msg model =
    case msg of
        ChangedImageUrl imageUrl ->
            ( { model | imageUrl = imageUrl }
            , Cmd.none
            )

        ChangedUsername username ->
            ( { model | username = username }
            , Cmd.none
            )

        ChangedBio bio ->
            ( { model | bio = bio }
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
                        \{ imageUrl, username, bio, email, maybePassword } ->
                            ( { model | errorMessages = [], isDisabled = True }
                            , UpdateUser.updateUser
                                options.apiUrl
                                { token = options.token
                                , imageUrl = imageUrl
                                , username = username
                                , bio = bio
                                , email = email
                                , maybePassword = maybePassword
                                , onResponse = GotUpdateUserResponse
                                }
                                |> Cmd.map options.onChange
                            )
                    , onFailure =
                        \errorMessages ->
                            ( { model | errorMessages = errorMessages }
                            , Cmd.none
                            )
                    }

        GotUpdateUserResponse result ->
            case result of
                Ok user ->
                    ( init
                        { imageUrl = user.imageUrl
                        , username = user.username
                        , bio = user.bio
                        , email = user.email
                        }
                    , Task.dispatch (options.onUpdatedUser user)
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
    { imageUrl : Url
    , username : Username
    , bio : String
    , email : Email
    , maybePassword : Maybe Password
    }


validate : Model -> V.Validation ValidatedFields
validate { imageUrl, username, bio, email, password } =
    V.succeed ValidatedFields
        |> V.required (validateImageUrl imageUrl)
        |> V.required (validateUsername username)
        |> V.required (validateBio bio)
        |> V.required (validateEmail email)
        |> V.required (validatePassword password)


validateImageUrl : String -> V.Validation Url
validateImageUrl rawUrl =
    let
        trimmedUrl =
            String.trim rawUrl
    in
    if String.isEmpty trimmedUrl then
        V.fail "image can't be blank"

    else
        case Url.fromString trimmedUrl of
            Just url ->
                V.succeed url

            Nothing ->
                V.fail "image is invalid"


validateUsername : String -> V.Validation Username
validateUsername rawUsername =
    case Username.fromString rawUsername of
        Just username ->
            V.succeed username

        Nothing ->
            V.fail "username can't be blank"


validateBio : String -> V.Validation String
validateBio =
    V.succeed


validateEmail : String -> V.Validation Email
validateEmail rawEmail =
    case Email.fromString rawEmail of
        Just email ->
            V.succeed email

        Nothing ->
            V.fail "email can't be blank"


validatePassword : String -> V.Validation (Maybe Password)
validatePassword rawPassword =
    case Password.fromString rawPassword of
        Ok password ->
            V.succeed <| Just password

        Err Password.Blank ->
            V.succeed Nothing

        Err (Password.TooShort expectedLength) ->
            V.fail <|
                String.concat
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



-- VIEW


type alias ViewOptions msg =
    { user : User
    , onLogout : msg
    , onChange : Msg -> msg
    }


view : ViewOptions msg -> Model -> H.Html msg
view { user, onLogout, onChange } { imageUrl, username, bio, email, password, isDisabled, errorMessages } =
    H.div []
        [ Navigation.view
            { role =
                Navigation.settings
                    { username = user.username
                    , imageUrl = user.imageUrl
                    }
            }
        , H.div
            [ HA.class "settings-page" ]
            [ H.div
                [ HA.class "container page" ]
                [ H.div
                    [ HA.class "row" ]
                    [ Settings.view
                        { classNames = "col-md-6 offset-md-3 col-xs-12"
                        , errorMessages = errorMessages
                        , form =
                            { imageUrl = imageUrl
                            , username = username
                            , bio = bio
                            , email = email
                            , password = password
                            , isDisabled = isDisabled
                            , onInputImageUrl = onChange << ChangedImageUrl
                            , onInputUsername = onChange << ChangedUsername
                            , onInputBio = onChange << ChangedBio
                            , onInputEmail = onChange << ChangedEmail
                            , onInputPassword = onChange << ChangedPassword
                            , onSubmit = onChange SubmittedForm
                            }
                        , onLogout = onLogout
                        }
                    ]
                ]
            ]
        , Footer.view
        ]
