module View.EditorForm exposing (EditorForm, Status(..), view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import View.Input as Input
import View.TagInput as TagInput
import View.Textarea as Textarea


type alias EditorForm msg =
    { title : String
    , description : String
    , body : String
    , tag : String

    --
    -- N.B. This can be better modeled as an ordered set.
    --
    -- Why?
    --
    -- 1. The order of the tags matter.
    -- 2. The tags should be unique.
    --
    , tags : List String
    , status : Status
    , onInputTitle : String -> msg
    , onInputDescription : String -> msg
    , onInputBody : String -> msg
    , onInputTag : String -> msg
    , onEnterTag : String -> msg
    , onRemoveTag : String -> msg
    , onSubmit : msg
    }


type Status
    = Invalid
    | Valid
    | Loading


view : EditorForm msg -> H.Html msg
view { title, description, body, tag, tags, status, onInputTitle, onInputDescription, onInputBody, onInputTag, onEnterTag, onRemoveTag, onSubmit } =
    let
        isFormDisabled =
            status == Invalid || status == Loading

        isFieldDisabled =
            status == Loading

        attrs =
            if isFormDisabled then
                []

            else
                [ HE.onSubmit onSubmit ]
    in
    H.form attrs
        [ H.fieldset []
            [ Input.view
                { name = "title"
                , type_ = "text"
                , placeholder = "Article Title"
                , value = title
                , isDisabled = isFieldDisabled
                , onInput = onInputTitle
                }
            , Input.view
                { name = "description"
                , type_ = "text"
                , placeholder = "What's this article about?"
                , value = description
                , isDisabled = isFieldDisabled
                , onInput = onInputDescription
                }
            , Textarea.view
                { name = "body"
                , placeholder = "Write your article (in markdown)"
                , rows = 8
                , value = body
                , isDisabled = isFieldDisabled
                , onInput = onInputBody
                }
            , TagInput.view
                { name = "tag"
                , placeholder = "Enter tags"
                , tag = tag
                , tags = tags
                , isDisabled = isFieldDisabled
                , onInput = onInputTag
                , onEnter = onEnterTag
                , onRemove = onRemoveTag
                }
            , H.button
                [ HA.class "btn btn-lg btn-primary pull-xs-right"
                , HA.type_ "submit"
                , HA.disabled isFormDisabled
                ]
                [ H.text "Publish Article" ]
            ]
        ]
