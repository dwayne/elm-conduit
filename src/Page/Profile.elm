module Page.Profile exposing (InitOptions, Model, Msg, UpdateOptions, ViewOptions, init, update, view)

import Api
import Api.GetProfile as GetProfile
import Data.Token exposing (Token)
import Data.User exposing (User)
import Data.Username exposing (Username)
import Data.Viewer as Viewer exposing (Viewer)
import Html as H
import Html.Attributes as HA
import Lib.RemoteData as RemoteData exposing (RemoteData)
import Time
import Url exposing (Url)
import View.Navigation as Navigation
import View.ProfileHeader as ProfileHeader



-- MODEL


type alias Model =
    { remoteDataProfile : RemoteData () GetProfile.Profile
    , showFavourites : Bool
    }


type alias InitOptions msg =
    { apiUrl : Url
    , maybeToken : Maybe Token
    , username : Username
    , showFavourites : Bool
    , onChange : Msg -> msg
    }


init : InitOptions msg -> ( Model, Cmd msg )
init { apiUrl, maybeToken, username, showFavourites, onChange } =
    ( { remoteDataProfile = RemoteData.Loading
      , showFavourites = showFavourites
      }
    , GetProfile.getProfile
        apiUrl
        { maybeToken = maybeToken
        , username = username
        , onResponse = GotGetProfileResponse
        }
        |> Cmd.map onChange
    )



-- UPDATE


type Msg
    = NoOp
    | GotGetProfileResponse (Result (Api.Error ()) GetProfile.Profile)


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

        GotGetProfileResponse result ->
            ( result
                |> Result.map
                    (\profile ->
                        { model | remoteDataProfile = RemoteData.Success profile }
                    )
                |> Result.withDefault model
            , Cmd.none
            )



-- VIEW


type alias ViewOptions msg =
    { zone : Time.Zone
    , viewer : Viewer
    , onChange : Msg -> msg
    }


view : ViewOptions msg -> Model -> H.Html msg
view { zone, viewer, onChange } { remoteDataProfile } =
    case viewer of
        Viewer.Guest ->
            viewAsGuest
                { zone = zone
                , remoteDataProfile = remoteDataProfile
                }

        Viewer.User user ->
            viewAsUser
                { zone = zone
                , user = user
                , remoteDataProfile = remoteDataProfile
                }
                |> H.map onChange


viewAsGuest :
    { zone : Time.Zone
    , remoteDataProfile : RemoteData () GetProfile.Profile
    }
    -> H.Html msg
viewAsGuest { zone, remoteDataProfile } =
    H.div []
        [ Navigation.view { role = Navigation.guest }
        , H.div [ HA.class "profile-page" ] <|
            case remoteDataProfile of
                RemoteData.Loading ->
                    []

                RemoteData.Success profile ->
                    [ ProfileHeader.view
                        { username = profile.username
                        , imageUrl = profile.imageUrl
                        , bio = profile.bio
                        , role = ProfileHeader.Guest
                        }
                    ]

                RemoteData.Failure _ ->
                    [ H.text "Unable to load the user's profile." ]
        ]


viewAsUser :
    { zone : Time.Zone
    , user : User
    , remoteDataProfile : RemoteData () GetProfile.Profile
    }
    -> H.Html Msg
viewAsUser { zone, user, remoteDataProfile } =
    H.div []
        [ Navigation.view
            { role =
                Navigation.profile
                    { username = user.username
                    , imageUrl = user.imageUrl
                    }
            }
        , H.div [ HA.class "profile-page" ] <|
            case remoteDataProfile of
                RemoteData.Loading ->
                    []

                RemoteData.Success profile ->
                    [ ProfileHeader.view
                        { username = profile.username
                        , imageUrl = profile.imageUrl
                        , bio = profile.bio
                        , role =
                            if profile.username == user.username then
                                ProfileHeader.Owner

                            else
                                ProfileHeader.User
                                    { isFollowing = profile.isFollowing

                                    --
                                    -- TODO: Implement follow/unfollow.
                                    --
                                    , isDisabled = False
                                    , onFollow = NoOp
                                    , onUnfollow = NoOp
                                    }
                        }
                    ]

                RemoteData.Failure _ ->
                    [ H.text "Unable to load the user's profile." ]
        ]
