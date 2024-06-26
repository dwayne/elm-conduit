module Page.Settings exposing (InitOptions, Model, Msg, UpdateOptions, ViewOptions, init, update, view)

import Api
import Api.UpdateUser as UpdateUser
import Browser as B
import Data.Email as Email exposing (Email)
import Data.Password exposing (Password)
import Data.Token exposing (Token)
import Data.User exposing (User)
import Data.Username as Username exposing (Username)
import Data.Validation as V
import Lib.Browser.Dom as BD
import Lib.Task as Task
import Lib.Validation as V
import Url exposing (Url)
import View.Column as Column
import View.Layout as Layout
import View.Navigation as Navigation
import View.Settings as Settings



-- MODEL


type alias Model =
    { imageUrl : String
    , username : String
    , bio : String
    , email : String
    , password : String
    , errorMessages : List String
    , isDisabled : Bool
    }


type alias InitOptions msg =
    { imageUrl : Url
    , username : Username
    , bio : String
    , email : Email
    , onChange : Msg -> msg
    }


init : InitOptions msg -> ( Model, Cmd msg )
init options =
    ( initModel options
    , BD.focus "imageUrl" FocusedImageUrl
        |> Cmd.map options.onChange
    )


initModel :
    { a
        | imageUrl : Url
        , username : Username
        , bio : String
        , email : Email
    }
    -> Model
initModel { imageUrl, username, bio, email } =
    { imageUrl = Url.toString imageUrl
    , username = Username.toString username
    , bio = bio
    , email = Email.toString email
    , password = ""
    , errorMessages = []
    , isDisabled = False
    }



-- UPDATE


type alias UpdateOptions msg =
    { apiUrl : Url
    , token : Token
    , onUpdatedUser : User -> msg
    , onChange : Msg -> msg
    }


type Msg
    = FocusedImageUrl
    | ChangedImageUrl String
    | ChangedUsername String
    | ChangedBio String
    | ChangedEmail String
    | ChangedPassword String
    | SubmittedForm
    | GotUpdateUserResponse (Result (Api.Error (List String)) User)


update : UpdateOptions msg -> Msg -> Model -> ( Model, Cmd msg )
update options msg model =
    case msg of
        FocusedImageUrl ->
            ( model, Cmd.none )

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
            Api.handleFormResponse
                (\user ->
                    ( initModel user
                    , Task.dispatch (options.onUpdatedUser user)
                    )
                )
                model
                result


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
        |> V.apply (V.imageUrl imageUrl)
        |> V.apply (V.username username)
        |> V.apply (V.bio bio)
        |> V.apply (V.email email)
        |> V.apply (V.optionalPassword password)



-- VIEW


type alias ViewOptions msg =
    { user : User
    , onLogout : msg
    , onChange : Msg -> msg
    }


view : ViewOptions msg -> Model -> B.Document msg
view { user, onLogout, onChange } { imageUrl, username, bio, email, password, errorMessages, isDisabled } =
    { title = "Settings"
    , body =
        [ Layout.view
            { name = "settings"
            , role =
                Navigation.settings
                    { username = user.username
                    , imageUrl = user.imageUrl
                    , onLogout = onLogout
                    }
            , maybeHeader = Nothing
            }
            [ Column.viewSingle Column.ExtraSmall
                [ Settings.view
                    { form =
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
                    , errorMessages = errorMessages
                    , onLogout = onLogout
                    }
                ]
            ]
        ]
    }
