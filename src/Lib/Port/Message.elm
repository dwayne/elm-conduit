module Lib.Port.Message exposing (Message, encode, string)

import Json.Encode as JE


type Message
    = Message
        { namespace : String
        , value : JE.Value
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
