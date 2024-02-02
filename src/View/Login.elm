module View.Login exposing (Login, view)

import Html as H
import Html.Attributes as HA
import View.LoginForm as LoginForm exposing (LoginForm)


type alias Login msg =
    { loginForm : LoginForm msg
    , errorMessages : List String
    }


view : String -> Login msg -> H.Html msg
view classNames { loginForm, errorMessages } =
    H.div
        [ HA.class classNames ]
        [ H.h1
            [ HA.class "text-xs-center" ]
            [ H.text "Sign in" ]
        , H.p
            [ HA.class "text-xs-center" ]
            [ H.a
                [ HA.href "./register.html" ]
                [ H.text "Need an account?" ]
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
        , LoginForm.view loginForm
        ]
