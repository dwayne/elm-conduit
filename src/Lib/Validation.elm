module Lib.Validation exposing (Validation(..), ap, map)


type Validation a
    = Success a
    | Failure (List String)


map : (a -> b) -> Validation a -> Validation b
map f va =
    case va of
        Success a ->
            Success (f a)

        Failure es ->
            Failure es


ap : Validation a -> Validation (a -> b) -> Validation b
ap va vf =
    case ( vf, va ) of
        ( Success f, Success a ) ->
            Success (f a)

        ( Failure es, Success _ ) ->
            Failure es

        ( Success _, Failure es ) ->
            Failure es

        ( Failure es1, Failure es2 ) ->
            Failure (es1 ++ es2)
