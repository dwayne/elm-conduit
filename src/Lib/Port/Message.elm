module Lib.Port.Message exposing (Message, empty, encode, string)

import Json.Encode as JE


type Message
    = Message
        { namespace : String
        , value : JE.Value
        }


empty : String -> Message
empty namespace =
    Message
        { namespace = namespace
        , value = JE.null
        }


string : String -> String -> Message
string namespace s =
    Message
        { namespace = namespace
        , value = JE.string s
        }


encode : Message -> JE.Value
encode (Message { namespace, value }) =
    JE.object
        [ ( "namespace", JE.string namespace )
        , ( "value", value )
        ]
