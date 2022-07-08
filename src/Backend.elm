module Backend exposing (..)

import Dict
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import List.Extra as List
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
                  , { title = "Home"
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
            let
                newId =
                    Dict.keys model.directories
                        |> List.sort
                        |> List.last
                        |> Maybe.withDefault 0
                        |> (+) 1

                newDirectoryNode =
                    { title = directoryName
                    , contents = []
                    , subdirectoriesIds = []
                    }

                newDirectories =
                    case maybeParentDirectoryId of
                        Just ( parentDirectoryId, _ ) ->
                            Dict.insert newId newDirectoryNode model.directories
                                |> Dict.update
                                    parentDirectoryId
                                    (Maybe.map
                                        (\parentDir ->
                                            { parentDir
                                                | subdirectoriesIds = ( newId, newDirectoryNode.title ) :: parentDir.subdirectoriesIds
                                            }
                                        )
                                    )

                        Nothing ->
                            Dict.insert newId newDirectoryNode model.directories
            in
            -- TODO
            ( { model | directories = newDirectories }
            , broadcast <|
                SendDirectoryToFrontend newId
                    (Just <| dbDirToDir newDirectories newDirectoryNode)
            )

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

        CreateContent directoryId content ->
            ( { model
                | directories =
                    Dict.update directoryId
                        (Maybe.map
                            (\directory -> { directory | contents = content :: directory.contents })
                        )
                        model.directories
              }
            , Cmd.none
            )


dbDirToDir : Dict.Dict Int DirectoryNode -> DirectoryNode -> Directory
dbDirToDir directories dbDirectory =
    Directory
        dbDirectory.title
        dbDirectory.contents
        (List.filterMap
            (\( directoryId, _ ) ->
                Dict.get directoryId directories
                    |> Maybe.andThen ((\{ title } -> Subdirectory title directoryId) >> Just)
            )
            dbDirectory.subdirectoriesIds
        )
