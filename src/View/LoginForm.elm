module View.LoginForm exposing (LoginForm, Status(..), view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import View.Input as Input


type alias LoginForm msg =
    { email : String
    , password : String
    , status : Status
    , onInputEmail : String -> msg
    , onInputPassword : String -> msg
    , onSubmit : msg
    }


type Status
    = Invalid
    | Valid
    | Loading


view : LoginForm msg -> H.Html msg
view { email, password, status, onInputEmail, onInputPassword, onSubmit } =
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
            [ H.text "Sign in" ]
        ]
