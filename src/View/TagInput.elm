module View.TagInput exposing (TagInput, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD


type alias TagInput msg =
    { name : String
    , placeholder : String
    , tag : String
    , tags : List String
    , isDisabled : Bool
    , onInput : String -> msg
    , onEnter : String -> msg
    , onRemove : String -> msg
    }


view : TagInput msg -> H.Html msg
view { name, placeholder, tag, tags, isDisabled, onInput, onEnter, onRemove } =
    let
        isEnabled =
            not isDisabled

        inputAttrs =
            toAttrs
                [ HA.class "form-control form-control-lg"
                , HA.name name
                , HA.type_ "text"
                , HA.placeholder placeholder
                , HA.value tag
                ]
                [ ( isDisabled, HA.disabled True )
                , ( isEnabled, HE.onInput onInput )
                , ( isEnabled, onEnterKeyUp (onEnter tag) )
                ]
    in
    H.fieldset
        [ HA.class "form-group" ]
        [ H.input inputAttrs []
        , viewTags isEnabled onRemove tags
        ]


viewTags : Bool -> (String -> msg) -> List String -> H.Html msg
viewTags isEnabled onRemove =
    List.map
        (\tag ->
            H.span
                [ HA.class "tag-default tag-pill" ]
                [ H.i
                    (toAttrs
                        [ HA.class "ion-close-round"
                        ]
                        [ ( isEnabled, HE.onClick (onRemove tag) )
                        ]
                    )
                    []
                , H.text tag
                ]
        )
        >> H.div [ HA.class "tag-list" ]


onEnterKeyUp : msg -> H.Attribute msg
onEnterKeyUp msg =
    let
        enterKeyDecoder =
            HE.keyCode
                |> JD.andThen
                    (\keyCode ->
                        if keyCode == 13 then
                            JD.succeed msg

                        else
                            JD.fail <| "ignored keyCode: " ++ String.fromInt keyCode
                    )
    in
    HE.on "keyup" enterKeyDecoder


toAttrs : List (H.Attribute msg) -> List ( Bool, H.Attribute msg ) -> List (H.Attribute msg)
toAttrs base =
    List.filterMap
        (\( isTrue, attr ) ->
            if isTrue then
                Just attr

            else
                Nothing
        )
        >> (++) base
