module View.Login exposing (Login, view)

import Html as H
import Html.Attributes as HA
import View.AuthErrors as AuthErrors
import View.LoginForm as LoginForm exposing (LoginForm)


type alias Login msg =
    { form : LoginForm msg
    , errorMessages : List String
    }


view : String -> Login msg -> H.Html msg
view classNames { form, errorMessages } =
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
        , AuthErrors.view errorMessages
        , LoginForm.view form
        ]
