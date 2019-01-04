module Route exposing (Route(..), routePraser, urlToRoute)

import Url
import Url.Parser exposing (Parser, map, oneOf, parse, s, top)


type Route
    = Home
    | SearchTweets
    | SearchUsers
    | NotFound


routePraser : Parser (Route -> a) a
routePraser =
    oneOf
        [ map Home top
        , map SearchTweets (s "searchTweets")
        , map SearchUsers (s "searchUsers")
        ]


urlToRoute : Url.Url -> Route
urlToRoute url =
    Maybe.withDefault NotFound (parse routePraser url)
