module View.Settings exposing (Settings, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import View.AuthErrors as AuthErrors
import View.SettingsForm as SettingsForm exposing (SettingsForm)


type alias Settings msg =
    { settingsForm : SettingsForm msg
    , errorMessages : List String
    , onLogout : msg
    }


view : String -> Settings msg -> H.Html msg
view classNames { settingsForm, errorMessages, onLogout } =
    H.div
        [ HA.class classNames ]
        [ H.h1
            [ HA.class "text-xs-center" ]
            [ H.text "Your Settings" ]
        , AuthErrors.view errorMessages
        , SettingsForm.view settingsForm
        , H.hr [] []
        , H.button
            [ HA.class "btn btn-outline-danger"
            , HA.type_ "button"
            , HE.onClick onLogout
            ]
            [ H.text "Or click here to logout." ]
        ]
