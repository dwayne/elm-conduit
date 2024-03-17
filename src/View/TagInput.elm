module View.TagInput exposing (ViewOptions, view)

import Data.Tag as Tag exposing (Tag)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD
import Lib.Html.Attributes as HA
import Lib.OrderedSet as OrderedSet exposing (OrderedSet)


type alias ViewOptions msg =
    { name : String
    , placeholder : String
    , tag : String
    , tags : OrderedSet Tag
    , isDisabled : Bool
    , onInput : String -> msg
    , onEnter : Tag -> msg
    , onRemove : Tag -> msg
    }


view : ViewOptions msg -> H.Html msg
view { name, placeholder, tag, tags, isDisabled, onInput, onEnter, onRemove } =
    let
        isEnabled =
            not isDisabled

        inputAttrs =
            HA.attrList
                [ HA.class "form-control form-control-lg"
                , HA.name name
                , HA.type_ "text"
                , HA.placeholder placeholder
                , HA.value tag
                ]
                [ ( HA.disabled True, isDisabled )
                , ( HE.onInput onInput, isEnabled )
                , ( onEnterKey tag onEnter, isEnabled )
                ]
    in
    H.fieldset
        [ HA.class "form-group" ]
        [ H.input inputAttrs []
        , viewTags isEnabled onRemove (OrderedSet.toList tags)
        ]


viewTags : Bool -> (Tag -> msg) -> List Tag -> H.Html msg
viewTags isEnabled onRemove =
    List.map
        (\tag ->
            H.span
                [ HA.class "tag-default tag-pill" ]
                [ H.i
                    (HA.attrList
                        [ HA.class "ion-close-round" ]
                        [ ( HE.onClick (onRemove tag), isEnabled )
                        ]
                    )
                    []
                , H.text <| Tag.toString tag
                ]
        )
        >> H.div [ HA.class "tag-list" ]


onEnterKey : String -> (Tag -> msg) -> H.Attribute msg
onEnterKey input toMsg =
    let
        enterKeyDecoder =
            HE.keyCode
                |> JD.andThen
                    (\keyCode ->
                        if keyCode == 13 then
                            case Tag.fromString input of
                                Just tag ->
                                    JD.succeed <| toMsg tag

                                Nothing ->
                                    JD.fail <| "invalid tag: \"" ++ input ++ "\""

                        else
                            JD.fail <| "ignored keyCode: " ++ String.fromInt keyCode
                    )
                |> JD.map alwaysPreventDefault
    in
    HE.preventDefaultOn "keydown" enterKeyDecoder


alwaysPreventDefault : msg -> ( msg, Bool )
alwaysPreventDefault msg =
    ( msg, True )
