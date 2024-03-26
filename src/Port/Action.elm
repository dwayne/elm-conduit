module Port.Action exposing (deleteToken, logError, saveToken)

import Data.Token as Token exposing (Token)
import Lib.Port.Message as Message
import Port


deleteToken : Cmd msg
deleteToken =
    Port.sendMessage <|
        Message.empty "deleteToken"


saveToken : Token -> Cmd msg
saveToken token =
    Port.sendMessage <|
        Message.string "saveToken" (Token.toString token)


logError : String -> Cmd msg
logError =
    Port.sendMessage << Message.string "logError"
