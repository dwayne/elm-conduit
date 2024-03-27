module View.Editor exposing (ViewOptions, view)

import Html as H
import Html.Attributes as HA
import View.AuthErrors as AuthErrors
import View.EditorForm as EditorForm


type alias ViewOptions msg =
    { form : EditorForm.ViewOptions msg
    , errorMessages : List String
    }


view : ViewOptions msg -> H.Html msg
view { form, errorMessages } =
    H.div []
        [ AuthErrors.view errorMessages
        , EditorForm.view form
        ]
