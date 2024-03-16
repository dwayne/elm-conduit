module Lib.Html.Attributes exposing (attrList)

import Html as H



--
-- TODO: Swap the tuple types.
--
-- Use List ( H.Attribute msg, Bool ) instead. See https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#classList.
--


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
