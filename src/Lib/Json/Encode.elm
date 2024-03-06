module Lib.Json.Encode exposing (url)

import Json.Encode as JE
import Url exposing (Url)


url : Url -> JE.Value
url =
    JE.string << Url.toString
