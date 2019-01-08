module Page.SearchTweets exposing (Model, Msg(..), MsgToMain(..), init, update, view)

import Css exposing (..)
import Html
import Html.Styled exposing (Html, a, div, h1, i, img, input, label, span, text)
import Html.Styled.Attributes as Attr
import Html.Styled.Events exposing (onClick, onInput)
import Http
import HttpBuilder exposing (..)
import Json.Decode as Decode exposing (Decoder, field, int, list, string)
import Json.Decode.Pipeline as DecodePipe
import MaterialComponents.Components as Mat
import PageType exposing (PageType)



---- MODEL ----


type alias Tweet =
    { text : String
    , createdAt : String
    , userName : String
    , screenName : String
    , profileImage : String
    , retweet : Int
    , fav : Int
    }


type alias Model =
    { tag : String
    , tweets : List Tweet
    }


init : ( Model, Cmd Msg )
init =
    ( { tag = ""
      , tweets = []
      }
    , Cmd.none
    )



---- UPDATE ----


type MsgToMain
    = NavToUser String


type Msg
    = NoOp
    | Tag String
    | SearchTag
    | ToMain MsgToMain
    | GotTweets (Result Http.Error (List Tweet))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- all messages are handled in Main.elm
        ToMain _ ->
            ( model, Cmd.none )

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
                , span
                    []
                    (List.map
                        (\tweet ->
                            div
                                [ Attr.css
                                    [ maxWidth (pct 80)
                                    , marginLeft auto
                                    , marginRight auto
                                    , marginTop (px 8)
                                    ]
                                ]
                                [ Mat.card "hi" (tweetCard tweet) ]
                        )
                        model.tweets
                    )
                ]
            ]
    }


tweetCard : Tweet -> Html Msg
tweetCard tweet =
    div
        [ Attr.css
            [ marginBottom (px 4) ]
        ]
        [ div
            [ Attr.css
                [ displayFlex
                , justifyContent spaceBetween
                , alignItems center
                ]
            ]
            [ userInfoView tweet
            , span
                [ Attr.css
                    [ marginRight (px 8) ]
                ]
                [ div [] [ text (String.slice 4 11 tweet.createdAt ++ String.right 4 tweet.createdAt) ]
                , div
                    []
                    [ span
                        [ Attr.css
                            [ marginRight (px 8) ]
                        ]
                        [ i [ Attr.class "material-icons" ] [ text "autorenew" ]
                        , span [] [ text (String.fromInt tweet.retweet) ]
                        ]
                    , span
                        []
                        [ i [ Attr.class "material-icons" ] [ text "favorite" ]
                        , span [] [ text (String.fromInt tweet.retweet) ]
                        ]
                    ]
                ]
            ]
        , formatLink tweet.text
        ]


userInfoView : Tweet -> Html Msg
userInfoView tweet =
    span
        [ Attr.css
            [ displayFlex
            , alignItems center
            , marginLeft (px 8)
            , textAlign start
            , cursor pointer
            ]
        , onClick (ToMain (NavToUser tweet.screenName))
        ]
        [ img
            [ Attr.src tweet.profileImage
            , Attr.css
                [ borderRadius2 (px 8) (px 21)
                ]
            ]
            []
        , span
            [ Attr.css
                [ marginLeft (px 8) ]
            ]
            [ div [] [ text tweet.userName ]
            , div [] [ text ("@" ++ tweet.screenName) ]
            ]
        ]


formatLink : String -> Html Msg
formatLink tweetContent =
    String.words tweetContent
        |> List.map
            (\word ->
                if String.contains "https://" word || String.contains "http://" word then
                    a
                        [ Attr.href word
                        , Attr.target "_blank"
                        ]
                        [ text (word ++ " ") ]

                else
                    text (word ++ " ")
            )
        |> (\html ->
                span [] html
           )



-- cardView : String -> Html Msg
-- cardView data =
--     Mat.card data


fetchTweets : String -> Cmd Msg
fetchTweets tag =
    HttpBuilder.get "http://localhost:4000/fetchTweets"
        |> withQueryParams [ ( "q", tag ++ " -filter:retweets -filter:replies" ), ( "lang", "en" ), ( "result", "popular" ), ( "tweet_mode", "extended" ) ]
        |> withExpectJson (list tweetDecoder)
        |> send GotTweets


tweetDecoder : Decoder Tweet
tweetDecoder =
    Decode.succeed Tweet
        |> DecodePipe.required "text" string
        |> DecodePipe.required "createdAt" string
        |> DecodePipe.required "userName" string
        |> DecodePipe.required "screenName" string
        |> DecodePipe.required "profileImage" string
        |> DecodePipe.required "retweet" int
        |> DecodePipe.required "fav" int
