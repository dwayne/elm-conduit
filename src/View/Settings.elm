module View.Settings exposing (ViewOptions, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import View.AuthErrors as AuthErrors
import View.SettingsForm as SettingsForm


type alias ViewOptions msg =
    { form : SettingsForm.ViewOptions msg
    , errorMessages : List String
    , onLogout : msg
    }


view : ViewOptions msg -> H.Html msg
view { form, errorMessages, onLogout } =
    H.div []
        [ H.h1
            [ HA.class "text-xs-center" ]
            [ H.text "Your Settings" ]
        , AuthErrors.view errorMessages
        , SettingsForm.view form
        , H.hr [] []
        , H.button
            [ HA.class "btn btn-outline-danger"
            , HA.type_ "button"
            , HE.onClick onLogout
            ]
            [ H.text "Or click here to logout." ]
        ]
