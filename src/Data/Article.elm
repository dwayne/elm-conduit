module Data.Article exposing (Article, Author, Fields, decoder, encode, fieldNames)

import Data.Slug as Slug exposing (Slug)
import Data.Tag as Tag exposing (Tag)
import Data.Timestamp as Timestamp exposing (Timestamp)
import Data.Total as Total exposing (Total)
import Data.Username as Username exposing (Username)
import Json.Decode as JD
import Json.Decode.Pipeline as JD
import Json.Encode as JE
import Lib.Json.Decode as JD
import Lib.NonEmptyString as NonEmptyString exposing (NonEmptyString)
import Url exposing (Url)


type alias Article =
    { slug : Slug
    , title : String
    , description : String
    , body : String
    , tags : List Tag
    , createdAt : Timestamp
    , isFavourite : Bool
    , totalFavourites : Total
    , author : Author
    }


type alias Author =
    { username : Username
    , imageUrl : Url
    , isFollowing : Bool
    }


type alias Fields =
    { title : NonEmptyString
    , description : NonEmptyString
    , body : NonEmptyString
    , tags : List Tag
    }


encode : Fields -> JE.Value
encode { title, description, body, tags } =
    JE.object
        [ ( "title", NonEmptyString.encode title )
        , ( "description", NonEmptyString.encode description )
        , ( "body", NonEmptyString.encode body )
        , ( "tagList", JE.list Tag.encode tags )
        ]


fieldNames : List String
fieldNames =
    [ "title"
    , "description"
    , "body"
    , "tagList"
    ]


decoder : JD.Decoder Article
decoder =
    JD.succeed Article
        |> JD.required "slug" Slug.decoder
        |> JD.required "title" JD.string
        |> JD.required "description" JD.string
        |> JD.required "body" JD.string
        |> JD.required "tagList" (JD.list Tag.decoder)
        |> JD.required "createdAt" Timestamp.decoder
        |> JD.required "favorited" JD.bool
        |> JD.required "favoritesCount" Total.decoder
        |> JD.required "author" authorDecoder


authorDecoder : JD.Decoder Author
authorDecoder =
    JD.map3 Author
        (JD.field "username" Username.decoder)
        (JD.field "image" JD.url)
        (JD.field "following" JD.bool)
