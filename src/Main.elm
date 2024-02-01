module Main exposing (main)

import Browser
import Html as H
import Html.Attributes as HA
import View.ArticlePreview as ArticlePreview
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
    , isFavourite : Bool
    }


init : Model
init =
    { homePageModel =
        { tagName = "elm"
        , active = FeedToggle.Global
        , isFavourite = False
        }
    }



-- UPDATE


type Msg
    = NoOp
    | ClickedFeedToggle FeedToggle.Feed
    | ClickedFavourite Bool


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model

        ClickedFeedToggle feed ->
            let
                homePageModel =
                    model.homePageModel

                newHomePageModel =
                    { homePageModel | active = feed }
            in
            { model | homePageModel = newHomePageModel }

        ClickedFavourite isFavourite ->
            let
                homePageModel =
                    model.homePageModel

                newHomePageModel =
                    { homePageModel | isFavourite = isFavourite }
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
viewHomePage { tagName, active, isFavourite } =
    H.div []
        [ H.h2 [] [ H.text "Home" ]
        , H.div
            [ HA.class "home-page" ]
            [ Banner.view
            , H.div
                [ HA.class "container page" ]
                [ H.div
                    [ HA.class "row" ]
                    [ H.div
                        [ HA.class "col-md-9" ]
                        [ FeedToggle.view
                            { hasPersonal = True
                            , tagName = tagName
                            , active = active
                            , onClick = ClickedFeedToggle
                            }
                        , ArticlePreview.view
                            { author =
                                { username = "Eric Simons"
                                , imageSrc = "http://i.imgur.com/Qr71crq.jpg"
                                }
                            , date = "January 20th"
                            , favourites =
                                if isFavourite then
                                    30

                                else
                                    29
                            , isFavourite = isFavourite
                            , slug = "how-to-build-webapps-that-scale"
                            , title = "How to build webapps that scale"
                            , description = "This is the description for the post."
                            , tags =
                                [ "realworld"
                                , "implementations"
                                ]
                            , onClick = ClickedFavourite
                            }
                        , ArticlePreview.view
                            { author =
                                { username = "Albert Pai"
                                , imageSrc = "http://i.imgur.com/N4VcUeJ.jpg"
                                }
                            , date = "January 20th"
                            , favourites = 32
                            , isFavourite = False
                            , slug = "the-song-you-wont-ever-stop-singing"
                            , title = "The song you won't ever stop singing. No matter how hard you try."
                            , description = "This is the description for the post."
                            , tags =
                                [ "realworld"
                                , "implementations"
                                ]
                            , onClick = always NoOp
                            }
                        ]
                    ]
                ]
            ]
        ]


viewFooter : H.Html msg
viewFooter =
    Footer.view
