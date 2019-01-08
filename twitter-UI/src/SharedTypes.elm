module SharedTypes exposing (User)


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
