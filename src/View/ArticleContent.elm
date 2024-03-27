module View.ArticleContent exposing (ViewOptions, view)

import Data.Tag as Tag exposing (Tag)
import Html as H
import Html.Attributes as HA
import Markdown


type alias ViewOptions =
    { description : String
    , body : String
    , tags : List Tag
    }


view : ViewOptions -> H.Html msg
view { description, body, tags } =
    H.div
        [ HA.class "article-content" ]
        [ H.p [] [ H.text description ]
        , viewMarkdown body
        , viewTags tags
        ]


viewMarkdown : String -> H.Html msg
viewMarkdown =
    Markdown.toHtml []


viewTags : List Tag -> H.Html msg
viewTags =
    List.map
        (\tag ->
            H.li
                [ HA.class "tag-default tag-pill tag-outline" ]
                [ H.text <| Tag.toString tag ]
        )
        >> H.ul [ HA.class "tag-list" ]
