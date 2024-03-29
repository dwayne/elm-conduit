module View.CommentForm exposing (ViewOptions, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Url exposing (Url)


type alias ViewOptions msg =
    { htmlId : String
    , comment : String
    , imageUrl : Url
    , isDisabled : Bool
    , onInputComment : String -> msg
    , onSubmit : msg
    }


view : ViewOptions msg -> H.Html msg
view { htmlId, comment, imageUrl, isDisabled, onInputComment, onSubmit } =
    let
        isButtonDisabled =
            isEmptyComment || isDisabled

        isEmptyComment =
            String.isEmpty <| String.trim comment

        baseAttrs =
            [ HA.class "card comment-form" ]

        optionalAttrs =
            if isDisabled then
                []

            else
                [ HE.onSubmit onSubmit ]

        attrs =
            baseAttrs ++ optionalAttrs
    in
    H.form attrs
        [ H.div
            [ HA.class "card-block" ]
            [ H.textarea
                [ HA.id htmlId
                , HA.class "form-control"
                , HA.placeholder "Write a comment..."
                , HA.rows 3
                , HA.value comment
                , if isDisabled then
                    HA.disabled True

                  else
                    HE.onInput onInputComment
                ]
                []
            ]
        , H.div
            [ HA.class "card-footer" ]
            [ H.img
                [ HA.class "comment-author-img"
                , HA.src <| Url.toString imageUrl
                ]
                []
            , H.button
                [ HA.class "btn btn-sm btn-primary"
                , HA.type_ "submit"
                , HA.disabled isButtonDisabled
                ]
                [ H.text "Post Comment" ]
            ]
        ]
