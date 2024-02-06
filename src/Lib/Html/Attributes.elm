module Lib.Html.Attributes exposing (attrList)

import Html as H


attrList : List (H.Attribute msg) -> List ( Bool, H.Attribute msg ) -> List (H.Attribute msg)
attrList base =
    List.filterMap
        (\( isTrue, attr ) ->
            if isTrue then
                Just attr

            else
                Nothing
        )
        >> (++) base
