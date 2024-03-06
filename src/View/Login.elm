module View.Login exposing (ViewOptions, view)

import Data.Route as Route
import Html as H
import Html.Attributes as HA
import View.AuthErrors as AuthErrors
import View.LoginForm as LoginForm


type alias ViewOptions msg =
    { classNames : String
    , errorMessages : List String
    , form : LoginForm.ViewOptions msg
    }


view : ViewOptions msg -> H.Html msg
view { classNames, errorMessages, form } =
    H.div
        [ HA.class classNames ]
        [ H.h1
            [ HA.class "text-xs-center" ]
            [ H.text "Sign in" ]
        , H.p
            [ HA.class "text-xs-center" ]
            [ H.a
                [ HA.href <| Route.toString Route.Register ]
                [ H.text "Need an account?" ]
            ]
        , AuthErrors.view errorMessages
        , LoginForm.view form
        ]
