module Page.Profile exposing (InitOptions, Model, Msg, UpdateOptions, ViewOptions, init, update, view)

import Data.Token exposing (Token)
import Data.User exposing (User)
import Data.Username exposing (Username)
import Data.Viewer as Viewer exposing (Viewer)
import Html as H
import Time
import Url exposing (Url)
import View.Navigation as Navigation



-- MODEL


type alias Model =
    {}


type alias InitOptions msg =
    { apiUrl : Url
    , maybeToken : Maybe Token
    , username : Username
    , showFavourites : Bool
    , onChange : Msg -> msg
    }


init : InitOptions msg -> ( Model, Cmd msg )
init _ =
    ( {}
    , Cmd.none
    )



-- UPDATE


type Msg
    = NoOp


type alias UpdateOptions msg =
    { apiUrl : Url
    , onChange : Msg -> msg
    }


update : UpdateOptions msg -> Msg -> Model -> ( Model, Cmd msg )
update _ msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )



-- VIEW


type alias ViewOptions msg =
    { zone : Time.Zone
    , viewer : Viewer
    , onChange : Msg -> msg
    }


view : ViewOptions msg -> Model -> H.Html msg
view { zone, viewer } _ =
    case viewer of
        Viewer.Guest ->
            viewAsGuest
                { zone = zone
                }

        Viewer.User user ->
            viewAsUser
                { zone = zone
                , user = user
                }


viewAsGuest :
    { zone : Time.Zone
    }
    -> H.Html msg
viewAsGuest { zone } =
    H.div []
        [ Navigation.view { role = Navigation.guest }
        ]


viewAsUser :
    { zone : Time.Zone
    , user : User
    }
    -> H.Html msg
viewAsUser { zone, user } =
    H.div []
        [ Navigation.view
            { role =
                Navigation.profile
                    { username = user.username
                    , imageUrl = user.imageUrl
                    }
            }
        ]
