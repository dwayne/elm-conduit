module View.ArticleHeader exposing (ViewOptions, view)

import Html as H
import Html.Attributes as HA
import View.ArticleMeta as ArticleMeta



--
-- TODO: Place ArticleMeta code into this module.
--


type alias ViewOptions msg =
    { title : String
    , meta : ArticleMeta.ViewOptions msg
    }


view : ViewOptions msg -> H.Html msg
view { title, meta } =
    H.div
        [ HA.class "banner" ]
        [ H.div
            [ HA.class "container" ]
            [ H.h1 [] [ H.text title ]
            , ArticleMeta.view meta
            ]
        ]
