module Main exposing (Model, Msg(..), Page(..), init, main, subscriptions, update, view)

-- Page imports

import Browser
import Browser.Navigation as Nav
import Html
import Html.Styled exposing (Html, div, h1, img, map, text, toUnstyled)
import Html.Styled.Attributes exposing (src)
import Page.Home as Home
import Page.SearchTweets as SearchTweets
import Page.SearchUser as SearchUsers
import PageType exposing (PageType)
import Route exposing (..)
import Url
import Url.Builder



---- MODEL ----


type Page
    = Home Home.Model
    | SearchTweets SearchTweets.Model
    | SearchUsers SearchUsers.Model
    | NotFound


type alias Model =
    { key : Nav.Key
    , uName : String
    , page : Page
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    changePage (urlToRoute url) { key = key, uName = "", page = NotFound }



---- UPDATE ----


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Home.Msg
    | SearchTweetsMsg SearchTweets.Msg
    | SearchUsersMsg SearchUsers.Msg
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            changePage (urlToRoute url) model

        HomeMsg subMsg ->
            case model.page of
                Home homeModel ->
                    updateWith Home HomeMsg model (Home.update subMsg homeModel)

                _ ->
                    ( model, Cmd.none )

        SearchTweetsMsg (SearchTweets.ToMain (SearchTweets.NavToUser userName)) ->
            Url.Builder.absolute [ "searchUsers" ] []
                |> Nav.pushUrl model.key
                |> (\cmd -> ( { model | uName = userName }, cmd ))

        SearchTweetsMsg subMsg ->
            case model.page of
                SearchTweets searchTweetsModel ->
                    updateWith SearchTweets SearchTweetsMsg model (SearchTweets.update subMsg searchTweetsModel)

                _ ->
                    ( model, Cmd.none )

        SearchUsersMsg subMsg ->
            case model.page of
                SearchUsers searchUsersModel ->
                    updateWith SearchUsers SearchUsersMsg model (SearchUsers.update subMsg searchUsersModel)

                _ ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Browser.Document Msg
view model =
    case model.page of
        Home homeModel ->
            routeView HomeMsg (Home.view homeModel)

        SearchTweets searchTweetsModel ->
            routeView SearchTweetsMsg (SearchTweets.view searchTweetsModel)

        SearchUsers searchUsersModel ->
            routeView SearchUsersMsg (SearchUsers.view searchUsersModel)

        NotFound ->
            { title = "NotFound Twitter-Demo"
            , body =
                [ toUnstyled
                    (div []
                        [ h1 [] [ text "404 Page Not Found" ]
                        ]
                    )
                ]
            }


routeView : (a -> msg) -> PageType a -> Browser.Document msg
routeView toMsg page =
    { title = page.title
    , body =
        [ toUnstyled
            (map toMsg <|
                page.content
            )
        ]
    }



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.application
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


changePage : Route -> Model -> ( Model, Cmd Msg )
changePage route model =
    case route of
        Route.Home ->
            Home.init
                |> updateWith Home HomeMsg model

        Route.SearchTweets ->
            SearchTweets.init
                |> updateWith SearchTweets SearchTweetsMsg model

        Route.SearchUsers ->
            SearchUsers.init model.uName
                |> updateWith SearchUsers SearchUsersMsg model

        Route.NotFound ->
            ( { model | page = NotFound }, Cmd.none )


updateWith : (subModel -> Page) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toPage toMsg model ( subModel, subCmd ) =
    ( { model | page = toPage subModel }, Cmd.map toMsg subCmd )
