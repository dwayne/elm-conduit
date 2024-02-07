module View.FeedTabs exposing (FeedTabs, Tab(..), view)

import Html as H
import View.Tabs as Tabs


type alias FeedTabs msg =
    { hasPersonal : Bool
    , tag : String
    , activeTab : Tab
    , isDisabled : Bool
    , onSwitch : Tab -> msg
    }


type Tab
    = Personal
    | Global
    | Tag String


view : FeedTabs msg -> H.Html msg
view { hasPersonal, tag, activeTab, isDisabled, onSwitch } =
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
                , if String.isEmpty tag then
                    Nothing

                  else
                    Just
                        { id = Tag tag
                        , title = "#" ++ tag
                        }
                ]
    in
    Tabs.view
        { name = "feed"
        , tabs = tabs
        , activeTab = activeTab
        , isDisabled = isDisabled
        , onSwitch = onSwitch
        }
