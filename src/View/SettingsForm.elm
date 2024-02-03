module View.SettingsForm exposing (SettingsForm, Status(..), view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import View.Field as Field
import View.Textarea as Textarea


type alias SettingsForm msg =
    { profilePicUrl : String
    , username : String
    , bio : String
    , email : String
    , newPassword : String
    , status : Status
    , onInputProfilePicUrl : String -> msg
    , onInputUsername : String -> msg
    , onInputBio : String -> msg
    , onInputEmail : String -> msg
    , onInputNewPassword : String -> msg
    , onSubmit : msg
    }


type Status
    = Invalid
    | Valid
    | Loading


view : SettingsForm msg -> H.Html msg
view { profilePicUrl, username, bio, email, newPassword, status, onInputProfilePicUrl, onInputUsername, onInputBio, onInputEmail, onInputNewPassword, onSubmit } =
    let
        isFormDisabled =
            status == Invalid || status == Loading

        isFieldDisabled =
            status == Loading

        attrs =
            if isFormDisabled then
                []

            else
                [ HE.onSubmit onSubmit ]
    in
    H.form attrs
        [ H.fieldset []
            [ Field.view
                { name = "profilePicUrl"
                , type_ = "text"
                , placeholder = "URL of profile picture"
                , value = profilePicUrl
                , isDisabled = isFieldDisabled
                , onInput = onInputProfilePicUrl
                }
            , Field.view
                { name = "username"
                , type_ = "text"
                , placeholder = "Your Name"
                , value = username
                , isDisabled = isFieldDisabled
                , onInput = onInputUsername
                }
            , Textarea.view
                { name = "bio"
                , placeholder = "Short bio about you"
                , rows = 8
                , value = bio
                , isDisabled = isFieldDisabled
                , onInput = onInputBio
                }
            , Field.view
                { name = "email"
                , type_ = "text"
                , placeholder = "Email"
                , value = email
                , isDisabled = isFieldDisabled
                , onInput = onInputEmail
                }
            , Field.view
                { name = "newPassword"
                , type_ = "password"
                , placeholder = "New Password"
                , value = newPassword
                , isDisabled = isFieldDisabled
                , onInput = onInputNewPassword
                }
            , H.button
                [ HA.class "btn btn-lg btn-primary pull-xs-right"
                , HA.type_ "submit"
                , HA.disabled isFormDisabled
                ]
                [ H.text "Update Settings" ]
            ]
        ]
