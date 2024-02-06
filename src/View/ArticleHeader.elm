module View.ArticleHeader exposing
    ( ArticleHeader
    , view
    )

import Html as H
import Html.Attributes as HA
import View.ArticleMeta as ArticleMeta exposing (ArticleMeta)


type alias ArticleHeader msg =
    { title : String
    , meta : ArticleMeta msg
    }


view : ArticleHeader msg -> H.Html msg
view { title, meta } =
    H.div
        [ HA.class "banner" ]
        [ H.div
            [ HA.class "container" ]
            [ H.h1 [] [ H.text title ]
            , ArticleMeta.view meta
            ]
        ]
