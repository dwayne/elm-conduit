module View.Textarea exposing (ViewOptions, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE


type alias ViewOptions msg =
    { name : String
    , placeholder : String
    , rows : Int
    , value : String
    , isDisabled : Bool
    , onInput : String -> msg
    }


view : ViewOptions msg -> H.Html msg
view { name, placeholder, rows, value, isDisabled, onInput } =
    H.fieldset
        [ HA.class "form-group" ]
        [ H.textarea
            [ HA.class "form-control form-control-lg"
            , HA.name name
            , HA.placeholder placeholder
            , HA.rows rows
            , HA.value value
            , if isDisabled then
                HA.disabled True

              else
                HE.onInput onInput
            ]
            []
        ]
