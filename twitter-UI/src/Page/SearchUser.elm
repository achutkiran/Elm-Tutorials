module Page.SearchUser exposing (Model, Msg(..), UserModel(..), init, update, view)

import Css exposing (..)
import Html
import Html.Styled exposing (Html, br, div, i, img, span, text)
import Html.Styled.Attributes as Attr
import Http
import HttpBuilder exposing (..)
import Json.Decode as Decode exposing (Decoder, bool, field, int, string)
import Json.Decode.Pipeline as DecodePipe
import MaterialComponents.Components as Mat
import PageType exposing (PageType)
import Reusable.UserCard as UserCard
import SharedTypes exposing (User)



---- MODEL ----


type UserModel
    = Init
    | WithUser (List User)


type ContentType
    = Followers
    | Friends
    | Search


type alias Model =
    { user : UserModel
    , name : String
    , contentType : ContentType
    }


init : String -> ( Model, Cmd Msg )
init name =
    let
        cmd =
            if name == "" then
                Cmd.none

            else
                fetchUsers name
    in
    ( { user = Init
      , name = name
      , contentType = Search
      }
    , cmd
    )



---- UPDATE ----


type Msg
    = NoOp
    | Input String
    | SearchUser
    | FetchFollowers String
    | FetchFriends String
    | GotUsers (Result Http.Error (List User))


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
                    errorHandler error model

        FetchFollowers name ->
            fetchFollowers name
                |> (\cmd -> ( model, cmd ))

        FetchFriends name ->
            fetchFriends name
                |> (\cmd -> ( model, cmd ))


errorHandler : Http.Error -> Model -> ( Model, Cmd Msg )
errorHandler error model =
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
        div
            [ Attr.css
                [ marginTop (px 8)
                ]
            ]
            [ Mat.textField "Enter User name" Input SearchUser "search"
            , case model.user of
                WithUser userData ->
                    div
                        [ Attr.css
                            [ maxWidth (pct 80)
                            , marginLeft auto
                            , marginRight auto
                            , marginTop (px 8)
                            ]
                        ]
                        (List.map
                            (\user ->
                                UserCard.view user (UserCard.Callback FetchFollowers FetchFriends NoOp NoOp NoOp)
                            )
                            userData
                        )

                Init ->
                    text ""
            ]
    }


fetchUsers : String -> Cmd Msg
fetchUsers name =
    HttpBuilder.get "http://localhost:4000/getUsers"
        |> withQueryParam "name" name
        |> withExpectJson (Decode.list userDecoder)
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
        |> DecodePipe.optional "bgUrl" string ""
        |> DecodePipe.required "profileUrl" string
        |> DecodePipe.required "textCol" string


fetchFollowers : String -> Cmd Msg
fetchFollowers name =
    HttpBuilder.get "http://localhost:4000/getFollowers"
        |> withQueryParams [ ( "name", name ), ( "cursor", "-1" ) ]
        |> withExpectJson (Decode.list userDecoder)
        |> send GotUsers


fetchFriends : String -> Cmd Msg
fetchFriends name =
    HttpBuilder.get "http://localhost:4000/getFriends"
        |> withQueryParams [ ( "name", name ), ( "cursor", "-1" ) ]
        |> withExpectJson (Decode.list userDecoder)
        |> send GotUsers
