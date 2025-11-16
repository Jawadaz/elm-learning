module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, div, text)
import Html.Attributes exposing (href, style)
import Pages.Canvas
import Pages.Counter
import Pages.Github
import Pages.Home
import Pages.Todo
import Route exposing (Route)
import Url exposing (Url)



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
            , Cmd.map TodoMsg todoCmd
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map CanvasMsg (Pages.Canvas.subscriptions model.canvasModel)



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
