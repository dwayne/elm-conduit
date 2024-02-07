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

import Html as H
import Html.Attributes as HA


type alias ViewOptions =
    { role : Role
    }


type Role
    = Guest (Maybe GuestItem)
    | User (Maybe UserItem) UserDetails


type alias UserDetails =
    { name : String
    , imageUrl : String
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
                , HA.href "./home.html"
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
        { href : String
        , text : String
        }
    | Icon
        { href : String
        , text : String
        , iconClass : String
        }
    | Image
        { href : String
        , text : String
        , src : String
        }


guestNavLinks : Maybe GuestItem -> List ( Bool, NavLink )
guestNavLinks maybeItem =
    [ ( maybeItem == Just GuestHome
      , Text { href = "./home.html", text = "Home" }
      )
    , ( maybeItem == Just Login
      , Text { href = "./login.html", text = "Sign in" }
      )
    , ( maybeItem == Just Register
      , Text { href = "./register.html", text = "Sign up" }
      )
    ]


userNavLinks : Maybe UserItem -> UserDetails -> List ( Bool, NavLink )
userNavLinks maybeItem { name, imageUrl } =
    [ ( maybeItem == Just UserHome
      , Text { href = "./home.html", text = "Home" }
      )
    , ( maybeItem == Just NewArticle
      , Icon
            { href = "./create-edit-article.html"
            , text = "New Article"
            , iconClass = "ion-compose"
            }
      )
    , ( maybeItem == Just Settings
      , Icon
            { href = "./settings.html"
            , text = "Settings"
            , iconClass = "ion-gear-a"
            }
      )
    , ( maybeItem == Just Profile
      , Image
            { href = "./profile.html"
            , text = name
            , src = imageUrl
            }
      )
    ]


viewNavLink : Bool -> NavLink -> H.Html msg
viewNavLink isActive navLink =
    let
        attrs href =
            [ HA.class "nav-link"
            , HA.classList [ ( "active", isActive ) ]
            , HA.href href
            ]
    in
    case navLink of
        Text { href, text } ->
            H.a (attrs href)
                [ H.text text ]

        Icon { href, text, iconClass } ->
            H.a (attrs href)
                [ H.i [ HA.class iconClass ] []
                , H.text <| "\u{00A0}" ++ text
                ]

        Image { href, text, src } ->
            H.a (attrs href)
                [ H.img
                    [ HA.class "user-pic"
                    , HA.src src
                    , HA.alt text
                    ]
                    []
                , H.text text
                ]
