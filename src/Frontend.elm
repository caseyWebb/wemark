module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html
import Html.Events as Events
import Lamdera
import Types exposing (..)
import Url


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , currentDirectoryPath = []
      , currentDirectory = Nothing
      , newDirectoryName = ""
      }
      --   TODO, fetch the root directory
    , Lamdera.sendToBackend (FetchDirectory 0)
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( model, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )

        UpdateNewDirectoryName updatedName ->
            ( { model | newDirectoryName = updatedName }, Cmd.none )

        CreateDirectoryFrontendMsg ->
            ( model, Lamdera.sendToBackend (CreateDirectoryToBackend model.newDirectoryName (List.head model.currentDirectoryPath)) )

        OpenDirectory directoryId ->
            ( model, Lamdera.sendToBackend <| FetchDirectory directoryId )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )

        SendDirectoryToFrontend directoryId maybeDirectory ->
            let
                directoryPath =
                    case maybeDirectory of
                        Just directory ->
                            (directoryId, directory.title) :: model.currentDirectoryPath

                        Nothing ->
                            model.currentDirectoryPath
            in
            ( { model | currentDirectory = maybeDirectory, currentDirectoryPath = directoryPath }, Cmd.none )


view : Model -> Browser.Document FrontendMsg
view model =
    { title = ""
    , body =
        case (Debug.log "model" model).currentDirectory of
            Just directory ->
                [ Html.h1 [] [ Html.text directory.title ]
                , Html.form [ Events.onSubmit <| CreateDirectoryFrontendMsg ]
                    [ Html.input [ Events.onInput UpdateNewDirectoryName ] [ Html.text model.newDirectoryName ]
                    , Html.button [] [ Html.text "Create Directory" ]
                    , viewSubdirectories directory.subdirectories
                    ]
                ]

            Nothing ->
                [ Html.text "Loading..." ]
    }


viewSubdirectories : List Subdirectory -> Html.Html FrontendMsg
viewSubdirectories subdirectories =
    Html.ul []
        (List.map
            (\{ title, id } -> Html.li [ Events.onClick <| OpenDirectory id ] [ Html.text title ])
            subdirectories
        )
