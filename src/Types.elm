module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict
import Url exposing (Url)


type alias FrontendModel =
    { currentDirectory : Maybe Directory
    , currentDirectoryPath : List ( Int, String )
    , key : Key
    , form : Form
    }


type alias Form =
    { newDirectoryName : String
    , newContentName : String
    , newContentUrl : String
    }


type alias BackendModel =
    { directories : Dict.Dict Int DirectoryNode
    }


type alias DirectoryNode =
    { title : String
    , contents : List Content
    , subdirectoriesIds : List ( Int, String )
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
    , url : String
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


type FormInput
    = DirectoryName
    | ContentName
    | ContentUrl


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | CreateDirectoryFrontendMsg
    | UpdateFormInput Form
    | OpenDirectory Int
    | ToBackend ToBackend


type ToBackend
    = NoOpToBackend
    | FetchDirectory Int
    | CreateDirectoryToBackend String (Maybe ( Int, String ))
    | CreateContent Int Content


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
    | SendDirectoryToFrontend Int (Maybe Directory)
