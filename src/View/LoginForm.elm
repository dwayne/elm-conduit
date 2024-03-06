module View.LoginForm exposing (ViewOptions, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import View.Input as Input


type alias ViewOptions msg =
    { email : String
    , password : String
    , isDisabled : Bool
    , onInputEmail : String -> msg
    , onInputPassword : String -> msg
    , onSubmit : msg
    }


view : ViewOptions msg -> H.Html msg
view { email, password, isDisabled, onInputEmail, onInputPassword, onSubmit } =
    let
        attrs =
            if isDisabled then
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
            , isDisabled = isDisabled
            , onInput = onInputEmail
            }
        , Input.view
            { name = "password"
            , type_ = "password"
            , placeholder = "Password"
            , value = password
            , isDisabled = isDisabled
            , onInput = onInputPassword
            }
        , H.button
            [ HA.class "btn btn-lg btn-primary pull-xs-right"
            , HA.type_ "submit"
            , HA.disabled isDisabled
            ]
            [ H.text "Sign in" ]
        ]
