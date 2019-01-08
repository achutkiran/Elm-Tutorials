module Page.Home exposing (Model, Msg(..), init, update, view)

import Html
import Html.Events exposing (onClick)
import Html.Styled exposing (Html, a, button, div, h1, text)
import Html.Styled.Attributes as Attr
import PageType exposing (PageType)



---- MODEL ----


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( {}
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> PageType Msg
view model =
    { title = "Home - Twitter Demo"
    , content =
        div [ Attr.id "dum" ]
            [ h1 [] [ text "Welcome to HomePage" ]
            , a [ Attr.class "mdc-button mdc-button--raised", Attr.href "/searchTweets" ] [ text "Search Tweets" ]
            , a [ Attr.class "mdc-button mdc-button--raised", Attr.href "/searchUsers" ] [ text "Search Users" ]
            ]
    }
