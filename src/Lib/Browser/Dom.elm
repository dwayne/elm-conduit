module Lib.Browser.Dom exposing (focus)

import Browser.Dom as BD
import Task


focus : String -> msg -> Cmd msg
focus id msg =
    BD.focus id
        |> Task.attempt (always msg)
