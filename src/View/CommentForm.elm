module View.CommentForm exposing (CommentForm, Status(..), view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE


type alias CommentForm msg =
    { comment : String
    , imageUrl : String
    , status : Status
    , onInputComment : String -> msg
    , onSubmit : msg
    }


type Status
    = Invalid
    | Valid
    | Loading


view : CommentForm msg -> H.Html msg
view { comment, imageUrl, status, onInputComment, onSubmit } =
    let
        isFormDisabled =
            status == Invalid || status == Loading

        isFieldDisabled =
            status == Loading

        baseAttrs =
            [ HA.class "card comment-form" ]

        optionalAttrs =
            if isFormDisabled then
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
                [ HA.class "form-control"
                , HA.placeholder "Write a comment..."
                , HA.rows 3
                , HA.value comment
                , if isFieldDisabled then
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
                , HA.src imageUrl
                ]
                []
            , H.button
                [ HA.class "btn btn-sm btn-primary"
                , HA.type_ "submit"
                , HA.disabled isFormDisabled
                ]
                [ H.text "Post Comment" ]
            ]
        ]
