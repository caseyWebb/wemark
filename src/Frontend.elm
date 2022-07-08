module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Lamdera
import List.Extra
import Types exposing (..)
import Url
import Url.Parser exposing (top)


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
      , form = Form "" "" ""
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

        UpdateFormInput newForm ->
            ( { model | form = newForm }, Cmd.none )

        CreateDirectoryFrontendMsg ->
            ( model, Lamdera.sendToBackend (CreateDirectoryToBackend model.form.newDirectoryName (List.head model.currentDirectoryPath)) )

        OpenDirectory directoryId ->
            ( { model
                | currentDirectoryPath =
                    List.Extra.takeWhileRight (Tuple.first >> (/=) directoryId) model.currentDirectoryPath
              }
            , Lamdera.sendToBackend <| FetchDirectory directoryId
            )

        ToBackend toBackendMsg ->
            ( model
            , Lamdera.sendToBackend toBackendMsg
            )


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
                            ( directoryId, directory.title ) :: model.currentDirectoryPath

                        Nothing ->
                            model.currentDirectoryPath
            in
            ( { model | currentDirectory = maybeDirectory, currentDirectoryPath = directoryPath }, Cmd.none )


view : Model -> Browser.Document FrontendMsg
view model =
    { title = ""
    , body =
        let
            form =
                model.form
        in
        case model.currentDirectory of
            Just directory ->
                [ Html.h1 [] (viewBreadcrumbs model.currentDirectoryPath)
                , Html.form [ Events.onSubmit <| CreateDirectoryFrontendMsg ]
                    [ Html.input
                        [ Events.onInput
                            (\newValue -> UpdateFormInput { form | newDirectoryName = newValue })
                        ]
                        [ Html.text model.form.newDirectoryName ]
                    , Html.button [] [ Html.text "Create Directory" ]
                    ]
                , Html.form
                    [ Events.onSubmit <|
                        ToBackend
                            (CreateContent 0
                                (Content model.form.newContentName model.form.newContentUrl [])
                            )
                    ]
                    [ Html.input
                        [ Events.onInput
                            (\newValue -> UpdateFormInput { form | newContentName = newValue })
                        ]
                        [ Html.text model.form.newContentName ]
                    , Html.input
                        [ Events.onInput
                            (\newValue -> UpdateFormInput { form | newContentUrl = newValue })
                        ]
                        [ Html.text model.form.newContentUrl ]
                    , Html.button [] [ Html.text "Create Content" ]
                    ]
                , viewContents directory.contents
                , viewSubdirectories directory.subdirectories
                ]

            Nothing ->
                [ Html.text "Loading..." ]
    }


viewBreadcrumbs : List ( Int, String ) -> List (Html.Html FrontendMsg)
viewBreadcrumbs currentDirectory =
    List.map
        (\( id, title ) ->
            Html.span
                [ Events.onClick (OpenDirectory id)
                ]
                [ Html.text title ]
        )
        (List.reverse currentDirectory)
        |> List.intersperse (Html.span [] [ Html.text " ➡️ " ])


viewContents : List Content -> Html.Html msg
viewContents contents =
    Html.div []
        [ Html.h2 [] [ Html.text "Contents" ]
        , Html.ul []
            (List.map
                (\{ title, url } ->
                    Html.li
                        []
                        [ Html.a
                            [ Attr.href (Url.fromString url |> Maybe.map Url.toString |> Maybe.withDefault "#") ]
                            [ Html.text title ]
                        ]
                )
                contents
            )
        ]


viewSubdirectories : List Subdirectory -> Html.Html FrontendMsg
viewSubdirectories subdirectories =
    Html.div []
        [ Html.h2 [] [ Html.text "Directories" ]
        , Html.ul []
            (List.map
                (\{ title, id } -> Html.li [ Events.onClick <| OpenDirectory id ] [ Html.text title ])
                subdirectories
            )
        ]
