module View.FeedToggle exposing (Feed(..), FeedToggle, view)

import Html as H
import View.Toggle as Toggle


type alias FeedToggle msg =
    { hasPersonal : Bool
    , tagName : String
    , active : Feed
    , onClick : Feed -> msg
    }


type Feed
    = Personal
    | Global
    | Tag String


view : FeedToggle msg -> H.Html msg
view { hasPersonal, tagName, active, onClick } =
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
                , if String.isEmpty tagName then
                    Nothing

                  else
                    Just
                        { id = Tag tagName
                        , title = "#" ++ tagName
                        }
                ]
    in
    Toggle.view
        { name = "feed"
        , tabs = tabs
        , active = active
        , onClick = onClick
        }
