module View.Navigation exposing
    ( Role
    , UserDetails
    , ViewOptions
    , guest
    , guestHome
    , login
    , newArticle
    , profile
    , register
    , settings
    , user
    , userHome
    , view
    )

import Data.Route as Route exposing (Route)
import Data.Username as Username exposing (Username)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD
import Url exposing (Url)


type alias ViewOptions msg =
    { role : Role msg
    }


type Role msg
    = Guest (Maybe GuestItem)
    | User (Maybe UserItem) (UserDetails msg)


type alias UserDetails msg =
    { username : Username
    , imageUrl : Url
    , onLogout : msg
    }


type GuestItem
    = GuestHome
    | Login
    | Register


type UserItem
    = UserHome
    | NewArticle
    | Settings
    | Profile


guest : Role msg
guest =
    Guest Nothing


guestHome : Role msg
guestHome =
    Guest <| Just GuestHome


login : Role msg
login =
    Guest <| Just Login


register : Role msg
register =
    Guest <| Just Register


user : UserDetails msg -> Role msg
user =
    User Nothing


userHome : UserDetails msg -> Role msg
userHome =
    User (Just UserHome)


newArticle : UserDetails msg -> Role msg
newArticle =
    User (Just NewArticle)


settings : UserDetails msg -> Role msg
settings =
    User (Just Settings)


profile : UserDetails msg -> Role msg
profile =
    User (Just Profile)


view : ViewOptions msg -> H.Html msg
view { role } =
    H.nav
        [ HA.class "navbar navbar-light" ]
        [ H.div
            [ HA.class "container" ]
            [ H.a
                [ HA.class "navbar-brand"
                , HA.href <| Route.toString Route.Home
                ]
                [ H.text "conduit" ]
            , viewNavItems role
            ]
        ]


viewNavItems : Role msg -> H.Html msg
viewNavItems role =
    let
        navLinks =
            case role of
                Guest maybeItem ->
                    guestNavLinks maybeItem

                User maybeItem userDetails ->
                    userNavLinks maybeItem userDetails
    in
    H.ul [ HA.class "nav navbar-nav pull-xs-right" ] <|
        List.map
            (\( isActive, navLink ) ->
                H.li
                    [ HA.class "nav-item" ]
                    [ viewNavLink isActive navLink
                    ]
            )
            navLinks


type NavLink msg
    = Text
        { route : Route
        , text : String
        }
    | Icon
        { route : Route
        , text : String
        , iconClass : String
        }
    | Image
        { route : Route
        , username : Username
        , imageUrl : Url
        }
    | Action
        { text : String
        , onClick : msg
        }


guestNavLinks : Maybe GuestItem -> List ( Bool, NavLink msg )
guestNavLinks maybeItem =
    [ ( maybeItem == Just GuestHome
      , Text { route = Route.Home, text = "Home" }
      )
    , ( maybeItem == Just Login
      , Text { route = Route.Login, text = "Sign in" }
      )
    , ( maybeItem == Just Register
      , Text { route = Route.Register, text = "Sign up" }
      )
    ]


userNavLinks : Maybe UserItem -> UserDetails msg -> List ( Bool, NavLink msg )
userNavLinks maybeItem { username, imageUrl, onLogout } =
    [ ( maybeItem == Just UserHome
      , Text { route = Route.Home, text = "Home" }
      )
    , ( maybeItem == Just NewArticle
      , Icon
            { route = Route.CreateArticle
            , text = "New Article"
            , iconClass = "ion-compose"
            }
      )
    , ( maybeItem == Just Settings
      , Icon
            { route = Route.Settings
            , text = "Settings"
            , iconClass = "ion-gear-a"
            }
      )
    , ( maybeItem == Just Profile
      , Image
            { route = Route.Profile username
            , username = username
            , imageUrl = imageUrl
            }
      )
    , ( False
      , Action { text = "Sign out", onClick = onLogout }
      )
    ]


viewNavLink : Bool -> NavLink msg -> H.Html msg
viewNavLink isActive navLink =
    let
        attrs route =
            [ HA.class "nav-link"
            , HA.classList [ ( "active", isActive ) ]
            , HA.href <| Route.toString route
            ]
    in
    case navLink of
        Text { route, text } ->
            H.a (attrs route)
                [ H.text text ]

        Icon { route, text, iconClass } ->
            H.a (attrs route)
                [ H.i [ HA.class iconClass ] []
                , H.text <| "\u{00A0}" ++ text
                ]

        Image { route, username, imageUrl } ->
            let
                text =
                    Username.toString username
            in
            H.a (attrs route)
                [ H.img
                    [ HA.class "user-pic"
                    , HA.src <| Url.toString imageUrl
                    , HA.alt text
                    ]
                    []
                , H.text text
                ]

        Action { text, onClick } ->
            H.a
                [ HA.class "nav-link"
                , HA.href Route.logoutPath
                , HE.preventDefaultOn "click" (JD.succeed ( onClick, True ))
                ]
                [ H.text text ]
