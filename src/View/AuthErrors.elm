module View.AuthErrors exposing (view)

import Html as H
import Html.Attributes as HA


view : List String -> H.Html msg
view errorMessages =
    if List.isEmpty errorMessages then
        H.text ""

    else
        errorMessages
            |> List.map viewErrorMessage
            |> H.ul [ HA.class "error-messages" ]


viewErrorMessage : String -> H.Html msg
viewErrorMessage errorMessage =
    H.li [] [ H.text errorMessage ]
