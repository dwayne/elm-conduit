module Lib.Html.Attributes exposing (attrList)

import Html as H


attrList : List (H.Attribute msg) -> List ( H.Attribute msg, Bool ) -> List (H.Attribute msg)
attrList base =
    List.filterMap
        (\( attr, isTrue ) ->
            if isTrue then
                Just attr

            else
                Nothing
        )
        >> (++) base
