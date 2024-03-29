module Api.ToggleFavourite exposing (Options, TotalFavourites, toggleFavourite)

import Api
import Data.Slug as Slug exposing (Slug)
import Data.Token exposing (Token)
import Data.Total as Total exposing (Total)
import Http
import Json.Decode as JD
import Lib.Either as Either
import Url exposing (Url)


type alias Options msg =
    { token : Token
    , slug : Slug
    , isFavourite : Bool
    , onResponse : Result (Api.Error ()) TotalFavourites -> msg
    }


toggleFavourite : Url -> Options msg -> Cmd msg
toggleFavourite baseUrl { token, slug, isFavourite, onResponse } =
    Api.request
        { method =
            if isFavourite then
                Api.POST

            else
                Api.DELETE
        , maybeToken = Just token
        , url =
            Api.buildUrl
                baseUrl
                [ "articles", Slug.toString slug, "favorite" ]
                []
                []
        , body = Http.emptyBody
        , onResponse = onResponse
        , eitherDefaultOrDecoder = Either.Right decoder
        , errorsDecoder = Api.emptyErrorsDecoder
        }


type alias TotalFavourites =
    { slug : Slug
    , isFavourite : Bool
    , totalFavourites : Total
    }


decoder : JD.Decoder TotalFavourites
decoder =
    JD.field "article" <|
        JD.map3 TotalFavourites
            (JD.field "slug" Slug.decoder)
            (JD.field "favorited" JD.bool)
            (JD.field "favoritesCount" Total.decoder)
