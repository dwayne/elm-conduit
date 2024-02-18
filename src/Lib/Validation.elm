module Lib.Validation exposing
    ( Validation
    , fail
    , required
    , succeed
    , withValidation
    )


type Validation a
    = Success a
    | Failure (List String)


succeed : a -> Validation a
succeed =
    Success


fail : String -> Validation a
fail message =
    Failure [ message ]


required : Validation a -> Validation (a -> b) -> Validation b
required va vf =
    case ( vf, va ) of
        ( Success f, Success a ) ->
            Success (f a)

        ( Failure es, Success _ ) ->
            Failure es

        ( Success _, Failure es ) ->
            Failure es

        ( Failure es1, Failure es2 ) ->
            Failure (es1 ++ es2)


withValidation :
    { onSuccess : a -> b
    , onFailure : List String -> b
    }
    -> Validation a
    -> b
withValidation { onSuccess, onFailure } va =
    case va of
        Success a ->
            onSuccess a

        Failure es ->
            onFailure es
