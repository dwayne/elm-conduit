module Lib.Url.Builder exposing (buildUrl)

import Url.Builder as UB


buildUrl : String -> List String -> List UB.QueryParameter -> List (Maybe UB.QueryParameter) -> String
buildUrl baseUrl pathSegments requiredParameters optionalParameters =
    UB.crossOrigin
        baseUrl
        pathSegments
        (requiredParameters ++ List.filterMap identity optionalParameters)
