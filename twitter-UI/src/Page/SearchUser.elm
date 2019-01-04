module Page.SearchUser exposing (Model, Msg(..), User, UserModel(..), init, update, view)

import Css exposing (..)
import Html
import Html.Styled exposing (br, div, i, img, span, text)
import Html.Styled.Attributes as Attr
import Http
import HttpBuilder exposing (..)
import Json.Decode as Decode exposing (Decoder, bool, field, int, string)
import Json.Decode.Pipeline as DecodePipe
import MaterialComponents.Components as Mat
import PageType exposing (PageType)



---- MODEL ----


type alias User =
    { name : String
    , screenName : String
    , description : String
    , verified : Bool
    , nFollowers : Int
    , nFriends : Int
    , nLists : Int
    , nFav : Int
    , nStatus : Int
    , createdOn : String
    , lan : String
    , bgColor : String
    , bgUrl : String
    , profileUrl : String
    , textCol : String
    }


type UserModel
    = Init
    | WithUser User


type alias Model =
    { user : UserModel
    , name : String
    }


init : ( Model, Cmd Msg )
init =
    ( { user = Init, name = "" }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | Input String
    | SearchUser
    | GotUsers (Result Http.Error User)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Input data ->
            ( { model | name = data }, Cmd.none )

        SearchUser ->
            fetchUsers model.name
                |> (\cmd -> ( model, cmd ))

        GotUsers result ->
            case result of
                Ok out ->
                    ( { model | user = WithUser out }, Cmd.none )

                Err error ->
                    let
                        errors =
                            case error of
                                Http.Timeout ->
                                    Debug.log "error" "timeout"

                                Http.NetworkError ->
                                    Debug.log "error" "networkError"

                                Http.BadPayload err data ->
                                    Debug.log "error" err

                                Http.BadUrl err ->
                                    Debug.log "error" "badurl"

                                Http.BadStatus code ->
                                    Debug.log "error" code.body
                    in
                    ( model, Cmd.none )



---- VIEW ----


view : Model -> PageType Msg
view model =
    { title = "User Search"
    , content =
        div [ Attr.css [ marginTop (px 9) ] ]
            [ Mat.textField "Enter User name" Input SearchUser "search"
            , case model.user of
                WithUser userData ->
                    div [ Attr.css [ maxWidth (pct 80), marginLeft auto, marginRight auto ] ]
                        [ Mat.card "user"
                            (span [ Attr.css [ backgroundColor (hex userData.bgColor), backgroundImage (url userData.bgUrl), color (hex userData.textCol), displayFlex, padding4 (px 0) (px 4) (px 4) (px 8) ] ]
                                [ span [ Attr.css [ displayFlex, flexDirection column, alignItems flexStart ] ]
                                    [ img [ Attr.src userData.profileUrl ] []
                                    , span []
                                        [ text userData.name
                                        , if userData.verified then
                                            i [ Attr.class "material-icons" ] [ text "verified_user" ]

                                          else
                                            text ""
                                        ]
                                    , span [ Attr.css [ marginBottom (px 8) ] ] [ text ("@" ++ userData.screenName) ]
                                    , span [ Attr.css [ marginBottom (px 8) ] ] [ text userData.description ]
                                    , span [] [ text (String.slice 4 8 userData.createdOn ++ String.right 4 userData.createdOn) ]
                                    ]
                                , span [ Attr.css [ displayFlex, flexGrow (num 1), alignItems center, justifyContent spaceBetween ] ]
                                    [ span []
                                        [ text "Followers"
                                        , br [] []
                                        , text (String.fromInt userData.nFollowers)
                                        ]
                                    , span []
                                        [ text "Friends"
                                        , br [] []
                                        , text (String.fromInt userData.nFriends)
                                        ]
                                    , span []
                                        [ text "Lists"
                                        , br [] []
                                        , text (String.fromInt userData.nLists)
                                        ]
                                    , span []
                                        [ text "Favorites"
                                        , br [] []
                                        , text (String.fromInt userData.nFav)
                                        ]
                                    , span []
                                        [ text "Status"
                                        , br [] []
                                        , text (String.fromInt userData.nStatus)
                                        ]
                                    ]
                                , text userData.lan
                                ]
                            )
                        ]

                Init ->
                    text ""
            ]
    }


fetchUsers : String -> Cmd Msg
fetchUsers name =
    HttpBuilder.get "http://localhost:4000/getUsers"
        |> withQueryParam "name" name
        |> withExpectJson userDecoder
        |> send GotUsers


userDecoder : Decoder User
userDecoder =
    Decode.succeed User
        |> DecodePipe.required "name" string
        |> DecodePipe.required "screenName" string
        |> DecodePipe.required "description" string
        |> DecodePipe.required "verified" bool
        |> DecodePipe.required "nFollowers" int
        |> DecodePipe.required "nFriends" int
        |> DecodePipe.required "nLists" int
        |> DecodePipe.required "nFav" int
        |> DecodePipe.required "nStatus" int
        |> DecodePipe.required "createdOn" string
        |> DecodePipe.required "lan" string
        |> DecodePipe.required "bgColor" string
        |> DecodePipe.required "bgUrl" string
        |> DecodePipe.required "profileUrl" string
        |> DecodePipe.required "textCol" string
