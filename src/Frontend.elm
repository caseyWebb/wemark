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
      , message = "Welcome to Lamdera! You're looking at the auto-generated base implementation. Check out src/Frontend.elm to start coding!"
      , root = Nothing
      , newDirectoryName = ""
      , currentDirectoryPath = []
      }
      --   TODO, fetch the root directory
    , Cmd.none
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


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )

        SendDirectoryToFrontend maybeDirectory ->
            ( model, Cmd.none )


view : Model -> Browser.Document FrontendMsg
view model =
    { title = ""
    , body =
        [ Html.form [ Events.onSubmit CreateDirectoryFrontendMsg ]
            [ Html.input [ Events.onInput UpdateNewDirectoryName ] [ Html.text model.newDirectoryName ]
            , Html.button [] [ Html.text "Create Directory" ]
            ]
        ]
    }
