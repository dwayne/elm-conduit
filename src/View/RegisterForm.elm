module View.RegisterForm exposing (RegisterForm, Status(..), view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import View.Input as Input


type alias RegisterForm msg =
    { username : String
    , email : String
    , password : String
    , status : Status
    , onInputUsername : String -> msg
    , onInputEmail : String -> msg
    , onInputPassword : String -> msg
    , onSubmit : msg
    }


type Status
    = Invalid
    | Valid
    | Loading


view : RegisterForm msg -> H.Html msg
view { username, email, password, status, onInputUsername, onInputEmail, onInputPassword, onSubmit } =
    let
        isFormDisabled =
            status == Invalid || status == Loading

        isFieldDisabled =
            status == Loading

        attrs =
            if isFormDisabled then
                []

            else
                [ HE.onSubmit onSubmit ]
    in
    H.form attrs
        [ Input.view
            { name = "username"
            , type_ = "text"
            , placeholder = "Username"
            , value = username
            , isDisabled = isFieldDisabled
            , onInput = onInputUsername
            }
        , Input.view
            { name = "email"
            , type_ = "text"
            , placeholder = "Email"
            , value = email
            , isDisabled = isFieldDisabled
            , onInput = onInputEmail
            }
        , Input.view
            { name = "password"
            , type_ = "password"
            , placeholder = "Password"
            , value = password
            , isDisabled = isFieldDisabled
            , onInput = onInputPassword
            }
        , H.button
            [ HA.class "btn btn-lg btn-primary pull-xs-right"
            , HA.type_ "submit"
            , HA.disabled isFormDisabled
            ]
            [ H.text "Sign up" ]
        ]
