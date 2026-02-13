module Data.Comments exposing (Comments, add, decoder, remove, toList)

import Data.Comment as Comment exposing (Comment)
import Json.Decode as JD
import Lib.Basics as Basics


type Comments
    = Comments (List Comment)


decoder : JD.Decoder Comments
decoder =
    Comment.decoder
        |> JD.list
        |> JD.map (Comments << sort)


sort : List Comment -> List Comment
sort =
    List.sortWith
        (\comment1 comment2 ->
            Comment.compare comment1 comment2
                |> Basics.reverseOrder
        )


add : Comment -> Comments -> Comments
add comment (Comments comments) =
    Comments (comment :: comments)


remove : String -> Comments -> Comments
remove id (Comments comments) =
    comments
        |> List.filter (.id >> (/=) id)
        |> Comments


toList : Comments -> List Comment
toList (Comments comments) =
    comments
