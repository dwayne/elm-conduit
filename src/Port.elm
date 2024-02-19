port module Port exposing (sendMessage)

import Json.Encode as JE
import Lib.Port.Message as Message exposing (Message)


port send : JE.Value -> Cmd msg


sendMessage : Message -> Cmd msg
sendMessage =
    Message.encode >> send
