module Lib.Function exposing (flip)


flip : (a -> b -> c) -> b -> a -> c
flip f b a =
    f a b
