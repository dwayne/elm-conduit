module Page.NotFound exposing (ViewOptions, view)

import Browser as B
import Data.Viewer as Viewer exposing (Viewer)
import Html as H
import View.Column as Column
import View.Layout as Layout
import View.Navigation as Navigation


type alias ViewOptions msg =
    { viewer : Viewer
    , onLogout : msg
    }


view : ViewOptions msg -> B.Document msg
view { viewer, onLogout } =
    { title = "Not Found"
    , body =
        [ Layout.view
            { name = "not-found-page"
            , role =
                case viewer of
                    Viewer.Guest ->
                        Navigation.guest

                    Viewer.User { username, imageUrl } ->
                        Navigation.user
                            { username = username
                            , imageUrl = imageUrl
                            , onLogout = onLogout
                            }
            , maybeHeader = Nothing
            }
            [ Column.viewSingle Column.Large
                [ H.text "The page you are looking for does not exist."
                ]
            ]
        ]
    }
