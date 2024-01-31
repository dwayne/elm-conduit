module View.Header exposing
    ( AuthenticatedItem(..)
    , Header(..)
    , UnauthenticatedItem(..)
    , view
    )

import Html as H
import Html.Attributes as HA


type Header
    = Unauthenticated (Maybe UnauthenticatedItem)
    | Authenticated String (Maybe AuthenticatedItem)


type UnauthenticatedItem
    = GuestHome
    | Login
    | Register


type AuthenticatedItem
    = Home
    | NewArticle
    | Settings
    | Profile


view : Header -> H.Html msg
view header =
    let
        navItems =
            List.map
                (\( isActive, navLink ) ->
                    H.li
                        [ HA.class "nav-item" ]
                        [ viewNavLink isActive navLink
                        ]
                )
            <|
                case header of
                    Unauthenticated maybeItem ->
                        unauthenticatedNavLinks maybeItem

                    Authenticated name maybeItem ->
                        authenticatedNavLinks name maybeItem
    in
    H.nav
        [ HA.class "navbar navbar-light" ]
        [ H.div
            [ HA.class "container" ]
            [ H.a
                [ HA.class "navbar-brand"
                , HA.href "./home.html"
                ]
                [ H.text "conduit" ]
            , H.ul
                [ HA.class "nav navbar-nav pull-xs-right" ]
                navItems
            ]
        ]


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


unauthenticatedNavLinks : Maybe UnauthenticatedItem -> List ( Bool, NavLink )
unauthenticatedNavLinks item =
    [ ( item == Just GuestHome
      , Text { href = "./home.html", text = "Home" }
      )
    , ( item == Just Login
      , Text { href = "./login.html", text = "Sign in" }
      )
    , ( item == Just Register
      , Text { href = "./register.html", text = "Sign up" }
      )
    ]


authenticatedNavLinks : String -> Maybe AuthenticatedItem -> List ( Bool, NavLink )
authenticatedNavLinks name item =
    [ ( item == Just Home
      , Text { href = "./home.html", text = "Home" }
      )
    , ( item == Just NewArticle
      , Icon
            { href = "./create-edit-article.html"
            , text = "New Article"
            , iconClass = "ion-compose"
            }
      )
    , ( item == Just Settings
      , Icon
            { href = "./settings.html"
            , text = "Settings"
            , iconClass = "ion-gear-a"
            }
      )
    , ( item == Just Profile
      , Image
            { href = ".profile.html"
            , text = name
            , src = "./images/smiley-cyrus.jpeg"
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
                , H.text "\u{00A0}"
                , H.text text
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
