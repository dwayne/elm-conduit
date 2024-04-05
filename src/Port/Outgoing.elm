port module Port.Outgoing exposing (deleteToken, logError, saveToken)

import Data.Token as Token exposing (Token)
import Json.Encode as JE
import Lib.Port.Message as Message exposing (Message)


deleteToken : Cmd msg
deleteToken =
    sendMessage <|
        Message.empty "deleteToken"


saveToken : Token -> Cmd msg
saveToken token =
    sendMessage <|
        Message.string "saveToken" (Token.toString token)


logError : String -> Cmd msg
logError =
    sendMessage << Message.string "logError"


sendMessage : Message -> Cmd msg
sendMessage =
    Message.encode >> send


port send : JE.Value -> Cmd msg
