port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, div, text)
import Html.Attributes exposing (href, style)
import Json.Decode as Decode
import Json.Encode
import Pages.Canvas
import Pages.Counter
import Pages.Github
import Pages.Home
import Pages.Todo
import Route exposing (Route)
import Url exposing (Url)
import Json.Decode as Decode
import Pages.Todo as Todo
import Platform.Cmd as Cmd



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , route : Maybe Route
    , counterModel : Pages.Counter.Model
    , githubModel : Pages.Github.Model
    , canvasModel : Pages.Canvas.Model
    , todoModel : Pages.Todo.Model
    }


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        route =
            Route.fromUrl url

        ( counterModel, counterCmd ) =
            Pages.Counter.init

        ( githubModel, githubCmd ) =
            Pages.Github.init

        ( canvasModel, canvasCmd ) =
            Pages.Canvas.init

        ( todoModel, todoCmd ) =
            Pages.Todo.init
    in
    ( { key = key
      , route = route
      , counterModel = counterModel
      , githubModel = githubModel
      , canvasModel = canvasModel
      , todoModel = todoModel
      }
    , Cmd.batch
        [ Cmd.map CounterMsg counterCmd
        , Cmd.map GithubMsg githubCmd
        , Cmd.map CanvasMsg canvasCmd
        , Cmd.map TodoMsg todoCmd
        ]
    )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | CounterMsg Pages.Counter.Msg
    | GithubMsg Pages.Github.Msg
    | CanvasMsg Pages.Canvas.Msg
    | TodoMsg Pages.Todo.Msg
    | LoadTodos Json.Encode.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | route = Route.fromUrl url }
            , Cmd.none
            )

        CounterMsg counterMsg ->
            let
                ( newCounterModel, counterCmd ) =
                    Pages.Counter.update counterMsg model.counterModel
            in
            ( { model | counterModel = newCounterModel }
            , Cmd.map CounterMsg counterCmd
            )

        GithubMsg githubMsg ->
            let
                ( newGithubModel, githubCmd ) =
                    Pages.Github.update githubMsg model.githubModel
            in
            ( { model | githubModel = newGithubModel }
            , Cmd.map GithubMsg githubCmd
            )

        CanvasMsg canvasMsg ->
            let
                ( newCanvasModel, canvasCmd ) =
                    Pages.Canvas.update canvasMsg model.canvasModel
            in
            ( { model | canvasModel = newCanvasModel }
            , Cmd.map CanvasMsg canvasCmd
            )

        TodoMsg todoMsg ->
            let
                ( newTodoModel, todoCmd ) =
                    Pages.Todo.update todoMsg model.todoModel
            in
            ( { model | todoModel = newTodoModel }
            , Cmd.batch
                [ Cmd.map TodoMsg todoCmd
                , saveTodos (Pages.Todo.encodeState newTodoModel) -- NEW!
                ]
            )
        
        LoadTodos json ->
            case Decode.decodeValue decodeTodos json of
                Ok todos ->
                    let
                        (initialModel, _) = Todo.init
                        loadedModel = Pages.Todo.setTodos todos initialModel
                    in
                    ( { model | todoModel = loadedModel }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map CanvasMsg (Pages.Canvas.subscriptions model.canvasModel)
        , loadTodos LoadTodos
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Elm Learning Project"
    , body =
        [ viewHeader
        , viewPage model
        ]
    }


viewHeader : Html Msg
viewHeader =
    div
        [ style "background-color" "#333"
        , style "padding" "20px"
        , style "color" "white"
        , style "margin-bottom" "20px"
        ]
        [ div []
            [ a [ href "/", style "color" "white", style "margin-right" "20px" ] [ text "Home" ]
            , a [ href "/counter", style "color" "white", style "margin-right" "20px" ] [ text "Counter" ]
            , a [ href "/github", style "color" "white", style "margin-right" "20px" ] [ text "GitHub" ]
            , a [ href "/canvas", style "color" "white", style "margin-right" "20px" ] [ text "Canvas" ]
            , a [ href "/todo", style "color" "white", style "margin-right" "20px" ] [ text "Todo" ]
            ]
        ]


viewPage : Model -> Html Msg
viewPage model =
    case model.route of
        Nothing ->
            div [ style "padding" "40px" ]
                [ text "404 - Page not found" ]

        Just Route.Home ->
            Pages.Home.view

        Just Route.Counter ->
            Html.map CounterMsg (Pages.Counter.view model.counterModel)

        Just Route.Github ->
            Html.map GithubMsg (Pages.Github.view model.githubModel)

        Just Route.Canvas ->
            Html.map CanvasMsg (Pages.Canvas.view model.canvasModel)

        Just Route.Todo ->
            Html.map TodoMsg (Pages.Todo.view model.todoModel)


port saveTodos : Json.Encode.Value -> Cmd msg


port loadTodos : (Json.Encode.Value -> msg) -> Sub msg



-- Decode a single Todo from JSON


decodeTodo : Decode.Decoder Pages.Todo.Todo
decodeTodo =
    Decode.map3 Pages.Todo.createTodo
        (Decode.field "id" Decode.int)
        (Decode.field "text" Decode.string)
        (Decode.field "complete" Decode.bool)



-- Decode a list of Todos


decodeTodos : Decode.Decoder (List Pages.Todo.Todo)
decodeTodos =
    Decode.list decodeTodo
