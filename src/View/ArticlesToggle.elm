module View.ArticlesToggle exposing (ArticlesToggle, Tab(..), view)

import Html as H
import View.Toggle as Toggle


type alias ArticlesToggle msg =
    { active : Tab
    , onClick : Tab -> msg
    }


type Tab
    = Personal
    | Favourites


view : ArticlesToggle msg -> H.Html msg
view { active, onClick } =
    Toggle.view
        { name = "articles"
        , tabs =
            [ { id = Personal
              , title = "My Articles"
              }
            , { id = Favourites
              , title = "Favourited Articles"
              }
            ]
        , active = active
        , onClick = onClick
        }
