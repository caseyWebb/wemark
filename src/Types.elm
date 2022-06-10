module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , message : String
    , root : Maybe Directory
    , newDirectoryName : String

    -- List of open directory ids in reverse depth order
    -- i.e. with root (0) -> foo (1) -> bar (2) open,
    -- this would be [2, 1, 0]
    , currentDirectoryPath : List Int
    }


type alias BackendModel =
    { directories : Dict.Dict Int Directory
    }


type Directory
    = Directory
        { title : String
        , subdirectories : List Directory
        , contents : List Content
        }


type alias Content =
    { title : String
    , comments : List Comment
    }


type alias Comment =
    { user : User
    , content : String
    }


type alias User =
    { id : Int
    , name : String
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | CreateDirectoryFrontendMsg
    | UpdateNewDirectoryName String


type ToBackend
    = NoOpToBackend
    | FetchDirectory Int
    | CreateDirectoryToBackend String (Maybe Int)


type BackendMsg
    = NoOpBackendMsg



-- | SendDirectory (Maybe Directory)
-- | CreateDirectoryBackendMsg String


type ToFrontend
    = NoOpToFrontend
    | SendDirectoryToFrontend (Maybe Directory)
