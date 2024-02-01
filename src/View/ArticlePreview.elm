module View.ArticlePreview exposing (ArticlePreview, Author, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE


type alias ArticlePreview msg =
    { author : Author
    , date : String
    , favourites : Int
    , isFavourite : Bool
    , slug : String
    , title : String
    , description : String
    , tags : List String
    , onClick : Bool -> msg
    }


type alias Author =
    { username : String
    , imageSrc : String
    }


view : ArticlePreview msg -> H.Html msg
view { author, date, favourites, isFavourite, onClick, slug, title, description, tags } =
    let
        profileHref =
            "./profile-" ++ author.username ++ ".html"
    in
    H.div
        [ HA.class "article-preview" ]
        [ H.div
            [ HA.class "article-meta" ]
            [ H.a
                [ HA.href profileHref ]
                [ H.img [ HA.src author.imageSrc ] [] ]
            , H.div
                [ HA.class "info" ]
                [ H.a
                    [ HA.class "author"
                    , HA.href profileHref
                    ]
                    [ H.text author.username ]
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
                , HE.onClick (onClick <| not isFavourite)
                ]
                [ H.i [ HA.class "ion-heart" ] []
                , H.text " "
                , H.text <| String.fromInt favourites
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
