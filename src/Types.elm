module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict
import Url exposing (Url)


type alias FrontendModel =
    { currentDirectory : Maybe Directory
    , currentDirectoryPath : List Int
    , key : Key
    , newDirectoryName : String
    }


type alias BackendModel =
    { directories : Dict.Dict Int DirectoryNode
    }


type alias DirectoryNode =
    { title : String
    , contents : List Content
    , subdirectoriesIds : List Int
    }


type alias Subdirectory =
    { title : String, id : Int }


type alias Directory =
    { title : String
    , contents : List Content
    , subdirectories : List Subdirectory
    }


type alias Content =
    { title : String
    , url : Url
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


type ToFrontend
    = NoOpToFrontend
    | SendDirectoryToFrontend Int (Maybe Directory)
