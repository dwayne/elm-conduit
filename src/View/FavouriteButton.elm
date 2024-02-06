module View.FavouriteButton exposing (FavouriteButton, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE


type alias FavouriteButton msg =
    { isFavourite : Bool
    , totalFavourites : Int
    , isDisabled : Bool
    , onFavourite : msg
    , onUnfavourite : msg
    }


view : FavouriteButton msg -> H.Html msg
view { isFavourite, totalFavourites, isDisabled, onFavourite, onUnfavourite } =
    let
        ( action, buttonClass, onClick ) =
            if isFavourite then
                ( "Unfavourite"
                , "btn-primary"
                , onUnfavourite
                )

            else
                ( "Favourite"
                , "btn-outline-primary"
                , onFavourite
                )
    in
    H.button
        [ HA.class "btn btn-sm"
        , HA.class buttonClass
        , if isDisabled then
            HA.disabled True

          else
            HE.onClick onClick
        ]
        [ H.i
            [ HA.class "ion-heart" ]
            []
        , H.text <| "\u{00A0} " ++ action ++ " Article "
        , H.span
            [ HA.class "counter" ]
            [ H.text <| "(" ++ String.fromInt totalFavourites ++ ")" ]
        ]
