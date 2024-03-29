module View.EditorForm exposing (ViewOptions, view)

import Data.Tag exposing (Tag)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Lib.OrderedSet exposing (OrderedSet)
import View.Input as Input
import View.TagInput as TagInput
import View.Textarea as Textarea


type alias ViewOptions msg =
    { title : String
    , description : String
    , body : String
    , tag : String
    , tags : OrderedSet Tag
    , isDisabled : Bool
    , onInputTitle : String -> msg
    , onInputDescription : String -> msg
    , onInputBody : String -> msg
    , onInputTag : String -> msg
    , onEnterTag : Tag -> msg
    , onRemoveTag : Tag -> msg
    , onSubmit : msg
    }


view : ViewOptions msg -> H.Html msg
view { title, description, body, tag, tags, isDisabled, onInputTitle, onInputDescription, onInputBody, onInputTag, onEnterTag, onRemoveTag, onSubmit } =
    let
        attrs =
            if isDisabled then
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
                , isDisabled = isDisabled
                , onInput = onInputTitle
                }
            , Input.view
                { name = "description"
                , type_ = "text"
                , placeholder = "What's this article about?"
                , value = description
                , isDisabled = isDisabled
                , onInput = onInputDescription
                }
            , Textarea.view
                { name = "body"
                , placeholder = "Write your article (in markdown)"
                , rows = 8
                , value = body
                , isDisabled = isDisabled
                , onInput = onInputBody
                }
            , TagInput.view
                { name = "tag"
                , placeholder = "Enter tags"
                , tag = tag
                , tags = tags
                , isDisabled = isDisabled
                , onInput = onInputTag
                , onEnter = onEnterTag
                , onRemove = onRemoveTag
                }
            , H.button
                [ HA.class "btn btn-lg btn-primary pull-xs-right"
                , HA.type_ "submit"
                , HA.disabled isDisabled
                ]
                [ H.text "Publish Article" ]
            ]
        ]
