module Lib.RemoteData exposing (RemoteData(..), isLoading)


type RemoteData e a
    = Loading
    | Success a
    | Failure e


isLoading : RemoteData e a -> Bool
isLoading remoteData =
    case remoteData of
        Loading ->
            True

        _ ->
            False
