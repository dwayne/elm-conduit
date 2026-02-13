module Data.Comment exposing (Comment, Commenter, compare, decoder)

import Data.Timestamp as Timestamp exposing (Timestamp)
import Data.Username as Username exposing (Username)
import Json.Decode as JD
import Lib.Json.Decode as JD
import Lib.NonEmptyString as NonEmptyString exposing (NonEmptyString)
import Url exposing (Url)


type alias Comment =
    { id : String
    , createdAt : Timestamp
    , body : NonEmptyString
    , commenter : Commenter
    }


type alias Commenter =
    { username : Username
    , imageUrl : Url
    }


decoder : JD.Decoder Comment
decoder =
    JD.map4 Comment
        (JD.field "id" JD.string)
        (JD.field "createdAt" Timestamp.decoder)
        (JD.field "body" NonEmptyString.decoder)
        (JD.field "author" <|
            JD.map2 Commenter
                (JD.field "username" Username.decoder)
                (JD.field "image" JD.imageUrl)
        )


compare : Comment -> Comment -> Order
compare comment1 comment2 =
    Timestamp.compare comment1.createdAt comment2.createdAt
