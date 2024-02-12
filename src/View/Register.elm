module View.Register exposing (ViewOptions, view)

import Data.Route as Route
import Html as H
import Html.Attributes as HA
import View.AuthErrors as AuthErrors
import View.RegisterForm as RegisterForm


type alias ViewOptions msg =
    { classNames : String
    , errorMessages : List String
    , form : RegisterForm.ViewOptions msg
    }


view : ViewOptions msg -> H.Html msg
view { classNames, errorMessages, form } =
    H.div
        [ HA.class classNames ]
        [ H.h1
            [ HA.class "text-xs-center" ]
            [ H.text "Sign up" ]
        , H.p
            [ HA.class "text-xs-center" ]
            [ H.a
                [ HA.href <| Route.toString Route.Login ]
                [ H.text "Have an account?" ]
            ]
        , AuthErrors.view errorMessages
        , RegisterForm.view form
        ]
