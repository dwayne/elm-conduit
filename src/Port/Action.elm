module Port.Action exposing (saveToken)

import Data.Token as Token exposing (Token)
import Lib.Port.Message as Message
import Port


saveToken : Token -> Cmd msg
saveToken =
    Token.toString
        >> Message.string "saveToken"
        >> Port.sendMessage
