module View.ArticleContent exposing (ArticleContent, view)

import Html as H
import Html.Attributes as HA
import Markdown


type alias ArticleContent =
    { description : String
    , body : String
    , tags : List String
    }


view : ArticleContent -> H.Html msg
view { description, body, tags } =
    H.div
        [ HA.class "row article-content" ]
        [ H.div
            [ HA.class "col-md-12" ]
            [ H.p [] [ H.text description ]
            , viewMarkdown body
            , viewTags tags
            ]
        ]


viewMarkdown : String -> H.Html msg
viewMarkdown =
    Markdown.toHtml []


viewTags : List String -> H.Html msg
viewTags =
    List.map
        (\tag ->
            H.li
                [ HA.class "tag-default tag-pill tag-outline" ]
                [ H.text tag ]
        )
        >> H.ul [ HA.class "tag-list" ]
