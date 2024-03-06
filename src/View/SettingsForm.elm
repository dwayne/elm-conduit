module View.SettingsForm exposing (ViewOptions, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import View.Input as Input
import View.Textarea as Textarea


type alias ViewOptions msg =
    { imageUrl : String
    , username : String
    , bio : String
    , email : String
    , password : String
    , isDisabled : Bool
    , onInputImageUrl : String -> msg
    , onInputUsername : String -> msg
    , onInputBio : String -> msg
    , onInputEmail : String -> msg
    , onInputPassword : String -> msg
    , onSubmit : msg
    }


view : ViewOptions msg -> H.Html msg
view { imageUrl, username, bio, email, password, isDisabled, onInputImageUrl, onInputUsername, onInputBio, onInputEmail, onInputPassword, onSubmit } =
    let
        attrs =
            if isDisabled then
                []

            else
                [ HE.onSubmit onSubmit ]
    in
    H.form attrs
        [ H.fieldset []
            [ Input.view
                { name = "imageUrl"
                , type_ = "text"
                , placeholder = "URL of profile picture"
                , value = imageUrl
                , isDisabled = isDisabled
                , onInput = onInputImageUrl
                }
            , Input.view
                { name = "username"
                , type_ = "text"
                , placeholder = "Your Name"
                , value = username
                , isDisabled = isDisabled
                , onInput = onInputUsername
                }
            , Textarea.view
                { name = "bio"
                , placeholder = "Short bio about you"
                , rows = 8
                , value = bio
                , isDisabled = isDisabled
                , onInput = onInputBio
                }
            , Input.view
                { name = "email"
                , type_ = "text"
                , placeholder = "Email"
                , value = email
                , isDisabled = isDisabled
                , onInput = onInputEmail
                }
            , Input.view
                { name = "password"
                , type_ = "password"
                , placeholder = "New Password"
                , value = password
                , isDisabled = isDisabled
                , onInput = onInputPassword
                }
            , H.button
                [ HA.class "btn btn-lg btn-primary pull-xs-right"
                , HA.type_ "submit"
                , HA.disabled isDisabled
                ]
                [ H.text "Update Settings" ]
            ]
        ]
