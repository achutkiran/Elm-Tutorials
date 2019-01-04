module PageType exposing (PageType)

import Html
import Html.Styled exposing (Html)


type alias PageType msg =
    { title : String
    , content : Html msg
    }
