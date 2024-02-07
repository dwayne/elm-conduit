module View.ArticleTabs exposing (ArticleTabs, Tab(..), view)

import Html as H
import View.Tabs as Tabs


type alias ArticleTabs msg =
    { activeTab : Tab
    , isDisabled : Bool
    , onSwitch : Tab -> msg
    }


type Tab
    = Personal
    | Favourites


view : ArticleTabs msg -> H.Html msg
view { activeTab, isDisabled, onSwitch } =
    Tabs.view
        { name = "articles"
        , tabs =
            [ { id = Personal
              , title = "My Articles"
              }
            , { id = Favourites
              , title = "Favourited Articles"
              }
            ]
        , activeTab = activeTab
        , isDisabled = isDisabled
        , onSwitch = onSwitch
        }
