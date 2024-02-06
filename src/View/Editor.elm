module View.Editor exposing (Editor, view)

import Html as H
import Html.Attributes as HA
import View.AuthErrors as AuthErrors
import View.EditorForm as EditorForm exposing (EditorForm)


type alias Editor msg =
    { form : EditorForm msg
    , errorMessages : List String
    }


view : String -> Editor msg -> H.Html msg
view classNames { form, errorMessages } =
    H.div
        [ HA.class classNames ]
        [ AuthErrors.view errorMessages
        , EditorForm.view form
        ]
