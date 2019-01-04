module Page.SearchTweets exposing (Model, Msg(..), init, update, view)

import Css exposing (..)
import Html
import Html.Styled exposing (Html, div, h1, i, input, label, span, text)
import Html.Styled.Attributes as Attr
import Html.Styled.Events exposing (onClick, onInput)
import Http
import HttpBuilder exposing (..)
import Json.Decode exposing (Decoder, field, list, string)
import MaterialComponents.Components as Mat
import PageType exposing (PageType)



---- MODEL ----


type alias Model =
    { tag : String
    , tweets : List String
    }


init : ( Model, Cmd Msg )
init =
    ( { tag = ""
      , tweets = []
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp
    | Tag String
    | SearchTag
    | GotTweets (Result Http.Error (List String))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchTag ->
            fetchTweets model.tag
                |> (\cmd -> ( model, cmd ))

        Tag tag ->
            ( { model | tag = tag }, Cmd.none )

        GotTweets result ->
            case result of
                Ok out ->
                    ( { model | tweets = out }, Cmd.none )

                Err error ->
                    Debug.log "error" error
                        |> (\x -> ( model, Cmd.none ))

        NoOp ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> PageType Msg
view model =
    { title = "Search Tweets"
    , content =
        div []
            [ {- Mat.toolbar "search" -}
              -- , h1 [] [ text "Search Tweets" ]
              -- , div [ Attr.class "mdc-text-field mdc-text-field--outlined mdc-text-field--with-trailing-icon" ]
              --     [ input [ Attr.type_ "text", Attr.class "mdc-text-field__input", onInput Tag ] []
              --     , i [ Attr.class "material-icons mdc-text-field__icon", Attr.tabindex 0, onClick SearchTag ] [ text "search" ]
              --     , div [ Attr.class "mdc-notched-outline" ]
              --         [ div [ Attr.class "mdc-notched-outline__leading" ] []
              --         , div [ Attr.class "mdc-notched-outline__notch" ]
              --             [ label [ Attr.class "mdc-floating-label" ] [ text "Enter Tweet Tag" ]
              --             ]
              --         , div [ Attr.class "mdc-notched-outline__trailing" ] []
              --         ]
              --     ]
              {- , -}
              div [ {- Attr.class "mdc-top-app-bar--fixed-adjust" -} Attr.css [ marginTop (px 10) ] ]
                [ Mat.textField "Enter Tweet Tag" Tag SearchTag "search"
                , Mat.card "hi" (div [] (List.map (\l -> span [] [ text l ]) model.tweets))
                ]
            ]
    }



-- cardView : String -> Html Msg
-- cardView data =
--     Mat.card data


fetchTweets : String -> Cmd Msg
fetchTweets tag =
    HttpBuilder.get "http://localhost:4000/fetchTweets"
        |> withQueryParams [ ( "q", tag ++ " -filter:retweets -filter:replies" ), ( "lang", "en" ), ( "result", "popular" ), ( "tweet_mode", "extended" ) ]
        |> withExpectJson tweetDecoder
        |> send GotTweets


tweetDecoder : Decoder (List String)
tweetDecoder =
    field "data" (list string)
