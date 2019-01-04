module MaterialComponents.Components exposing (card, textField, toolbar)

-- import Html.Attributes as Attr

import Css exposing (..)
import Html
import Html.Styled exposing (Html, a, button, div, header, i, input, label, section, span, text)
import Html.Styled.Attributes as Attr
import Html.Styled.Events exposing (onClick, onInput)


textField : String -> (String -> msg) -> msg -> String -> Html msg
textField labelText onInputEvent onClickEvent iconText =
    div [ Attr.class "mdc-text-field mdc-text-field--outlined mdc-text-field--with-trailing-icon" ]
        [ input [ Attr.type_ "text", Attr.class "mdc-text-field__input", onInput onInputEvent ] []
        , i [ Attr.class "material-icons mdc-text-field__icon", Attr.tabindex 0, onClick onClickEvent ] [ text iconText ]
        , div [ Attr.class "mdc-notched-outline" ]
            [ div [ Attr.class "mdc-notched-outline__leading" ] []
            , div [ Attr.class "mdc-notched-outline__notch" ]
                [ label [ Attr.class "mdc-floating-label" ] [ text labelText ]
                ]
            , div [ Attr.class "mdc-notched-outline__trailing" ] []
            ]
        ]


card : String -> Html msg -> Html msg
card title data =
    -- div [ Attr.class "mdc-card" ]
    --     [ data
    --     ]
    div [ Attr.class "mdc-card" ]
        [ data

        -- , div [ Attr.class "mdc-card__actions", Attr.hidden True ]
        --     [ div [ Attr.class "mdc-card__action-buttons" ]
        --         [ button [ Attr.class "mdc-button mdc-card__action mdc-card__action--button" ]
        --             [ span [ Attr.class "mdc-button__label" ] [ text "Action 1" ] ]
        --         , button [ Attr.class "mdc-button mdc-card__action mdc-card__action--button" ]
        --             [ span [ Attr.class "mdc-button__label" ] [ text "Action 2" ] ]
        --         ]
        -- ]
        ]


toolbar : String -> Html msg
toolbar title =
    header [ Attr.class "mdc-top-app-bar mdc-top-app-bar--fixed" ]
        [ div [ Attr.class "mdc-top-app-bar__row" ]
            [ section [ Attr.class "mdc-top-app-bar__section mdc-top-app-bar__section--align-start" ]
                -- [ a [ Attr.href "#", Attr.class "material-icons mdc-top-app-bar__navigation-icon" ] [ text "menu" ]
                [ span [ Attr.class "mdc-top-app-bar__title" ] [ text title ]
                ]
            , section [ Attr.class "mdc-top-app-bar__section mdc-top-app-bar__section--align-end" ]
                [ button [ Attr.class "material-icons mdc-top-app-bar__action-item" ] [ text "account_circle" ] ]
            ]
        ]
