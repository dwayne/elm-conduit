module View.FeedTabs exposing (Tab(..), ViewOptions, activeTag, view)

import Data.Tag as Tag exposing (Tag)
import Html as H
import View.Tabs as Tabs


type alias ViewOptions msg =
    { hasPersonal : Bool
    , maybeTag : Maybe Tag
    , activeTab : Tab
    , isDisabled : Bool
    , onSwitch : Tab -> msg
    }


type Tab
    = Personal
    | Global
    | Tag Tag


activeTag : Tab -> Maybe Tag
activeTag tab =
    case tab of
        Tag tag ->
            Just tag

        _ ->
            Nothing


view : ViewOptions msg -> H.Html msg
view { hasPersonal, maybeTag, activeTab, isDisabled, onSwitch } =
    let
        tabs =
            List.filterMap identity <|
                [ if hasPersonal then
                    Just
                        { id = Personal
                        , title = "Your Feed"
                        }

                  else
                    Nothing
                , Just
                    { id = Global
                    , title = "Global Feed"
                    }
                , maybeTag
                    |> Maybe.map
                        (\tag ->
                            { id = Tag tag
                            , title = "#" ++ Tag.toString tag
                            }
                        )
                ]
    in
    Tabs.view
        { name = "feed"
        , tabs = tabs
        , activeTab = activeTab
        , isDisabled = isDisabled
        , onSwitch = onSwitch
        }
