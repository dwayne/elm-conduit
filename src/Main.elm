module Main exposing (main)

import Browser
import Html as H
import Html.Attributes as HA
import View.Banner as Banner
import View.FeedToggle as FeedToggle
import View.Footer as Footer
import View.Header as Header


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { homePageModel : HomePageModel
    }


type alias HomePageModel =
    { tagName : String
    , active : FeedToggle.Feed
    }


init : Model
init =
    { homePageModel =
        { tagName = "elm"
        , active = FeedToggle.Global
        }
    }



-- UPDATE


type Msg
    = ClickedFeedToggle FeedToggle.Feed


update : Msg -> Model -> Model
update msg model =
    case msg of
        ClickedFeedToggle feed ->
            let
                homePageModel =
                    model.homePageModel

                newHomePageModel =
                    { homePageModel | active = feed }
            in
            { model | homePageModel = newHomePageModel }



-- VIEW


view : Model -> H.Html Msg
view { homePageModel } =
    H.div []
        [ viewHeader
        , viewHomePage homePageModel
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


viewHomePage : HomePageModel -> H.Html Msg
viewHomePage { tagName, active } =
    H.div []
        [ H.h2 [] [ H.text "Home" ]
        , H.div
            [ HA.class "home-page" ]
            [ Banner.view
            , H.h3 [] [ H.text "Feed Toggle" ]
            , FeedToggle.view
                { hasPersonal = True
                , tagName = tagName
                , active = active
                , onClick = ClickedFeedToggle
                }
            ]
        ]


viewFooter : H.Html msg
viewFooter =
    Footer.view
