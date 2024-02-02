module View.Register exposing (Register, view)

import Html as H
import Html.Attributes as HA
import View.RegisterForm as RegisterForm exposing (RegisterForm)


type alias Register msg =
    { registerForm : RegisterForm msg
    , errorMessages : List String
    }


view : String -> Register msg -> H.Html msg
view classNames { registerForm, errorMessages } =
    H.div
        [ HA.class classNames ]
        [ H.h1
            [ HA.class "text-xs-center" ]
            [ H.text "Sign up" ]
        , H.p
            [ HA.class "text-xs-center" ]
            [ H.a
                [ HA.href "./login.html" ]
                [ H.text "Have an account?" ]
            ]
        , if List.isEmpty errorMessages then
            H.text ""

          else
            H.ul [ HA.class "error-messages" ] <|
                List.map
                    (\errorMessage ->
                        H.li [] [ H.text errorMessage ]
                    )
                    errorMessages
        , RegisterForm.view registerForm
        ]
