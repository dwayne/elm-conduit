module View.DefaultLayout exposing (ViewOptions, view)

import Html as H
import View.Footer as Footer
import View.Navigation as Navigation


type alias ViewOptions =
    { role : Navigation.Role
    }


view : ViewOptions -> List (H.Html msg) -> H.Html msg
view { role } content =
    H.div [] <|
        List.concat
            [ [ Navigation.view { role = role } ]
            , content
            , [ Footer.view ]
            ]
