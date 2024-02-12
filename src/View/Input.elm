module View.Input exposing (ViewOptions, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE



--
-- TODO: Remove isDisabled field.
--


type alias ViewOptions msg =
    { name : String
    , type_ : String
    , placeholder : String
    , value : String
    , isDisabled : Bool
    , onInput : String -> msg
    }


view : ViewOptions msg -> H.Html msg
view { name, type_, placeholder, value, isDisabled, onInput } =
    H.fieldset
        [ HA.class "form-group" ]
        [ H.input
            [ HA.class "form-control form-control-lg"
            , HA.name name
            , HA.type_ type_
            , HA.placeholder placeholder
            , HA.value value
            , if isDisabled then
                HA.disabled True

              else
                HE.onInput onInput
            ]
            []
        ]
