module Main exposing (main)

import Html as H
import View.Header as Header


main : H.Html msg
main =
    H.div []
        [ Header.view (Header.Unauthenticated Nothing)
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
