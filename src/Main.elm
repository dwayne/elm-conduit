module Main exposing (main)

import Html as H
import Html.Attributes as HA
import View.Banner as Banner
import View.Footer as Footer
import View.Header as Header


main : H.Html msg
main =
    H.div []
        [ viewHeader
        , viewHomePage
        , viewFooter
        ]


viewHeader : H.Html msg
viewHeader =
    H.div []
        [ H.h2 [] [ H.text "Header" ]
        , Header.view (Header.Unauthenticated Nothing)
        , H.hr [] []
        , Header.view (Header.Unauthenticated <| Just Header.GuestHome)
        , H.hr [] []
        , Header.view (Header.Unauthenticated <| Just Header.Login)
        , H.hr [] []
        , Header.view (Header.Unauthenticated <| Just Header.Register)
        , H.hr [] []
        , Header.view (Header.Authenticated "Eric Simons" Nothing)
        , H.hr [] []
        , Header.view (Header.Authenticated "Eric Simons" <| Just Header.Home)
        , H.hr [] []
        , Header.view (Header.Authenticated "Eric Simons" <| Just Header.NewArticle)
        , H.hr [] []
        , Header.view (Header.Authenticated "Eric Simons" <| Just Header.Settings)
        , H.hr [] []
        , Header.view (Header.Authenticated "Eric Simons" <| Just Header.Profile)
        ]


viewHomePage : H.Html msg
viewHomePage =
    H.div []
        [ H.h2 [] [ H.text "Home" ]
        , H.div
            [ HA.class "home-page" ]
            [ Banner.view
            ]
        ]


viewFooter : H.Html msg
viewFooter =
    Footer.view
