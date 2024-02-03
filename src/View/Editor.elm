module View.Editor exposing (Editor, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import View.AuthErrors as AuthErrors
import View.EditorForm as EditorForm exposing (EditorForm)


type alias Editor msg =
    { editorForm : EditorForm msg
    , errorMessages : List String
    }


view : String -> Editor msg -> H.Html msg
view classNames { editorForm, errorMessages } =
    H.div
        [ HA.class classNames ]
        [ AuthErrors.view errorMessages
        , EditorForm.view editorForm
        ]
