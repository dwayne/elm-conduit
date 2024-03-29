module Lib.RemoteData exposing (RemoteData(..), map)


type RemoteData e a
    = Loading
    | Success a
    | Failure e


map : (a -> b) -> RemoteData e a -> RemoteData e b
map f remoteData =
    case remoteData of
        Loading ->
            Loading

        Success a ->
            Success (f a)

        Failure e ->
            Failure e
