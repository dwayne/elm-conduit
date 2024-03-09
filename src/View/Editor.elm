module View.Editor exposing (ViewOptions, view)

import Html as H
import Html.Attributes as HA
import View.AuthErrors as AuthErrors
import View.EditorForm as EditorForm


type alias ViewOptions msg =
    { classNames : String
    , errorMessages : List String
    , form : EditorForm.ViewOptions msg
    }


view : ViewOptions msg -> H.Html msg
view { classNames, errorMessages, form } =
    H.div
        [ HA.class classNames ]
        [ AuthErrors.view errorMessages
        , EditorForm.view form
        ]
