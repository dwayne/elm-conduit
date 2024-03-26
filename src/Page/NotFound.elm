module Page.NotFound exposing (view)

import Data.Viewer as Viewer exposing (Viewer)
import Html as H
import Html.Attributes as HA
import View.Footer as Footer
import View.Navigation as Navigation


view : Viewer -> H.Html msg
view viewer =
    H.div []
        [ Navigation.view
            { role =
                case viewer of
                    Viewer.Guest ->
                        Navigation.guest

                    Viewer.User { username, imageUrl } ->
                        Navigation.user
                            { username = username
                            , imageUrl = imageUrl
                            }
            }
        , H.div
            [ HA.class "container page" ]
            [ H.text "The page you are looking for does not exist." ]
        , Footer.view
        ]
