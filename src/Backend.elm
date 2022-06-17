module Backend exposing (..)

import Dict
import Lamdera exposing (ClientId, SessionId)
import Types exposing (..)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Sub.none
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { directories =
            Dict.fromList
                [ ( 0
                  , { title = "Welcome to We Mark!"
                    , contents = []
                    , subdirectoriesIds = [ 1, 2, 3 ]
                    }
                  )
                , ( 1
                  , { title = "Subdir 1"
                    , contents = []
                    , subdirectoriesIds = []
                    }
                  )
                , ( 2
                  , { title = "Subdir 2"
                    , contents = []
                    , subdirectoriesIds = []
                    }
                  )
                , ( 3
                  , { title = "Subdir 3"
                    , contents = []
                    , subdirectoriesIds = []
                    }
                  )
                ]
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )

        CreateDirectoryToBackend directoryName maybeParentDirectoryId ->
            -- TODO
            ( model, Cmd.none )

        FetchDirectory directoryId ->
            ( model
            , Lamdera.sendToFrontend
                clientId
                (SendDirectoryToFrontend directoryId
                    (model.directories
                        |> Dict.get directoryId
                        |> Maybe.andThen (dbDirToDir model.directories >> Just)
                    )
                )
            )


dbDirToDir : Dict.Dict Int DirectoryNode -> DirectoryNode -> Directory
dbDirToDir directories dbDirectory =
    Directory
        dbDirectory.title
        dbDirectory.contents
        (List.filterMap
            (\directoryId ->
                Dict.get directoryId directories
                    |> Maybe.andThen ((\{ title } -> Subdirectory title directoryId) >> Just)
            )
            dbDirectory.subdirectoriesIds
        )
