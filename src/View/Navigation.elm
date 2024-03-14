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
import Url exposing (Url)


type alias ViewOptions =
    { role : Role
    }


type Role
    = Guest (Maybe GuestItem)
    | User (Maybe UserItem) UserDetails


type alias UserDetails =
    { username : Username
    , imageUrl : Url
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


guest : Role
guest =
    Guest Nothing


guestHome : Role
guestHome =
    Guest <| Just GuestHome


login : Role
login =
    Guest <| Just Login


register : Role
register =
    Guest <| Just Register


user : UserDetails -> Role
user =
    User Nothing


userHome : UserDetails -> Role
userHome =
    User (Just UserHome)


newArticle : UserDetails -> Role
newArticle =
    User (Just NewArticle)


settings : UserDetails -> Role
settings =
    User (Just Settings)


profile : UserDetails -> Role
profile =
    User (Just Profile)


view : ViewOptions -> H.Html msg
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


viewNavItems : Role -> H.Html msg
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


type NavLink
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


guestNavLinks : Maybe GuestItem -> List ( Bool, NavLink )
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


userNavLinks : Maybe UserItem -> UserDetails -> List ( Bool, NavLink )
userNavLinks maybeItem { username, imageUrl } =
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
    ]


viewNavLink : Bool -> NavLink -> H.Html msg
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
