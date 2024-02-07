module Main exposing (main)

import Browser as B
import Browser.Navigation exposing (Key)
import Html as H
import Url exposing (Url)


main : Program Flags Model Msg
main =
    B.application
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        }


type alias Flags =
    ()


-- MODEL


type alias Model =
    { url : Url
    , key : Key
    }



init : Flags -> Url -> Key -> ( Model, Cmd msg )
init _ url key =
    ( { url = url
      , key = key
      }
    , Cmd.none
    )


-- UPDATE


type Msg
    = ClickedLink B.UrlRequest
    | ChangedUrl Url


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        ClickedLink _ ->
            ( model
            , Cmd.none
            )

        ChangedUrl url ->
            ( { model | url = url }
            , Cmd.none
            )


-- VIEW


view : Model -> B.Document msg
view { url } =
    { title = "Conduit"
    , body =
        [ H.text <| "url = " ++ Url.toString url
        ]
    }
