module View.FavouriteButton exposing (ViewOptions, view)

import Data.Total as Total exposing (Total)
import Html as H
import Html.Attributes as HA
import Html.Events as HE


type alias ViewOptions msg =
    { isFavourite : Bool
    , totalFavourites : Total
    , isDisabled : Bool
    , onFavourite : msg
    , onUnfavourite : msg
    }


view : ViewOptions msg -> H.Html msg
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
            [ H.text <| "(" ++ Total.toString totalFavourites ++ ")" ]
        ]
