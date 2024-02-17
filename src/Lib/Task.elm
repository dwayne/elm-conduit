module Lib.Task exposing (dispatch)

import Task


dispatch : msg -> Cmd msg
dispatch =
    Task.succeed >> Task.perform identity
