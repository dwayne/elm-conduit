module View.ArticlePreview exposing (ArticlePreview, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE


type alias ArticlePreview msg =
    { name : String
    , imageUrl : String
    , date : String
    , totalFavourites : Int
    , isFavourite : Bool
    , slug : String
    , title : String
    , description : String
    , tags : List String
    , onToggleFavourite : Bool -> msg
    }


view : ArticlePreview msg -> H.Html msg
view { name, imageUrl, date, totalFavourites, isFavourite, onToggleFavourite, slug, title, description, tags } =
    let
        profileHref =
            "./profile-" ++ name ++ ".html"
    in
    H.div
        [ HA.class "article-preview" ]
        [ H.div
            [ HA.class "article-meta" ]
            [ H.a
                [ HA.href profileHref ]
                [ H.img [ HA.src imageUrl ] [] ]
            , H.div
                [ HA.class "info" ]
                [ H.a
                    [ HA.class "author"
                    , HA.href profileHref
                    ]
                    [ H.text name ]
                , H.span
                    [ HA.class "date" ]
                    [ H.text date ]
                ]
            , H.button
                [ HA.class "btn btn-sm pull-xs-right"
                , HA.class <|
                    if isFavourite then
                        "btn-primary"

                    else
                        "btn-outline-primary"
                , HE.onClick (onToggleFavourite <| not isFavourite)
                ]
                [ H.i [ HA.class "ion-heart" ] []
                , H.text " "
                , H.text <| String.fromInt totalFavourites
                ]
            ]
        , H.a
            [ HA.class "preview-link"
            , HA.href <| "./article-" ++ slug ++ ".html"
            ]
            [ H.h1 [] [ H.text title ]
            , H.p [] [ H.text description ]
            , H.span [] [ H.text "Read more..." ]
            , H.ul [ HA.class "tag-list" ] <|
                List.map
                    (\tag ->
                        H.li
                            [ HA.class "tag-default tag-pill tag-outline" ]
                            [ H.text tag ]
                    )
                    tags
            ]
        ]
