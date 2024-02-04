module View.FeedToggle exposing (FeedToggle, Tab(..), view)

import Html as H
import View.Toggle as Toggle


type alias FeedToggle msg =
    { hasPersonal : Bool
    , tag : String
    , active : Tab
    , onClick : Tab -> msg
    }


type Tab
    = Personal
    | Global
    | Tag String


view : FeedToggle msg -> H.Html msg
view { hasPersonal, tag, active, onClick } =
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
    Toggle.view
        { name = "feed"
        , tabs = tabs
        , active = active
        , onClick = onClick
        }
