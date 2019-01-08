module Reusable.UserCard exposing (Callback, view)

import Css exposing (..)
import Html
import Html.Styled exposing (Html, br, button, div, i, img, span, text)
import Html.Styled.Attributes as Attr
import Html.Styled.Events exposing (onClick)
import MaterialComponents.Components as Mat
import SharedTypes exposing (User)


type alias Callback msg =
    { followersCb : String -> msg
    , friendsCb : String -> msg
    , listCb : msg
    , favCb : msg
    , statusCb : msg
    }


view : User -> Callback msg -> Html msg
view userData cb =
    div
        [ Attr.css
            [ maxWidth (pct 80)
            , marginLeft auto
            , marginRight auto
            , marginTop (px 8)
            ]
        ]
        [ Mat.card "user" (cardViewData userData cb)
        ]


cardViewData : User -> Callback msg -> Html msg
cardViewData userData cb =
    span
        [ Attr.css
            [ backgroundColor (hex userData.bgColor)
            , backgroundImage (url userData.bgUrl)
            , color (hex userData.textCol)
            , displayFlex
            , padding4 (px 0) (px 4) (px 4) (px 8)
            ]
        ]
        [ mainUserDetailsView userData
        , userStatsView userData cb
        ]


mainUserDetailsView : User -> Html msg
mainUserDetailsView userData =
    span
        [ Attr.css
            [ displayFlex
            , flexDirection column
            , alignItems flexStart
            ]
        ]
        [ img
            [ Attr.src userData.profileUrl ]
            []
        , span
            []
            [ text userData.name
            , if userData.verified then
                i [ Attr.class "material-icons" ] [ text "verified_user" ]

              else
                text ""
            ]
        , span
            [ Attr.css
                [ marginBottom (px 8) ]
            ]
            [ text ("@" ++ userData.screenName) ]
        , span
            [ Attr.css
                [ marginBottom (px 8) ]
            ]
            [ text userData.description ]
        , span
            []
            [ text (String.slice 4 8 userData.createdOn ++ String.right 4 userData.createdOn) ]
        ]


userStatsView : User -> Callback msg -> Html msg
userStatsView userData cb =
    span
        [ Attr.css
            [ displayFlex
            , flexGrow (num 1)
            , alignItems center
            , justifyContent spaceBetween
            ]
        ]
        [ span
            []
            [ button [ Attr.class "mdc-button", onClick (cb.followersCb userData.screenName) ] [ text "Followers" ]
            , br [] []
            , text (String.fromInt userData.nFollowers)
            ]
        , span
            []
            [ button [ Attr.class "mdc-button", onClick (cb.friendsCb userData.screenName) ] [ text "Friends" ]
            , br [] []
            , text (String.fromInt userData.nFriends)
            ]
        , span
            []
            [ button [ Attr.class "mdc-button", onClick cb.listCb ] [ text "Lists" ]
            , br [] []
            , text (String.fromInt userData.nLists)
            ]
        , span
            []
            [ button [ Attr.class "mdc-button", onClick cb.favCb ] [ text "Favorites" ]
            , br [] []
            , text (String.fromInt userData.nFav)
            ]
        , span
            []
            [ button [ Attr.class "mdc-button", onClick cb.statusCb ] [ text "Status" ]
            , br [] []
            , text (String.fromInt userData.nStatus)
            ]
        ]
