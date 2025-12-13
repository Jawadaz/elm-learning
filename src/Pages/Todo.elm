module Pages.Todo exposing (Model, Msg, createTodo, encodeState, init, update, view, setTodos, Todo)

import Html exposing (Html, br, button, div, input, text)
import Html.Attributes exposing (checked, disabled, placeholder, style, type_, value)
import Html.Events exposing (on, onClick, onDoubleClick, onInput)
import Json.Decode as Decode
import Json.Encode as Encode


type alias Todo =
    { id : Int
    , text : String
    , complete : Bool
    }


type Filter
    = All
    | Active
    | Complete


type Msg
    = AddTodo
    | ToggleComplete Int
    | UpdateInput String
    | DeleteTodo Int
    | UpdateCurrentEdit String
    | SaveEdit
    | CancelEdit
    | InitiateEdit Int String
    | KeyDownInEdit Int
    | SetFilter Filter
    | ClearCompleted


type alias Model =
    { todosList : List Todo
    , nextId : Int
    , currentInput : String
    , editId : Int
    , currentEdit : String
    , currentFilter : Filter
    }


init : ( Model, Cmd Msg )
init =
    ( { todosList = [], nextId = 0, currentInput = "", editId = -1, currentEdit = "", currentFilter = All }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateInput input ->
            ( { model | currentInput = input }, Cmd.none )

        AddTodo ->
            if model.currentInput /= "" then
                let
                    newTodo : Todo
                    newTodo =
                        { id = model.nextId, text = model.currentInput, complete = False }
                in
                ( { model
                    | currentInput = ""
                    , todosList = newTodo :: model.todosList
                    , nextId = model.nextId + 1
                  }
                , Cmd.none
                )

            else
                ( model, Cmd.none )

        ToggleComplete id ->
            ( { model
                | todosList =
                    List.map
                        (\a ->
                            if a.id == id then
                                toggleCompleteFlag a

                            else
                                a
                        )
                        model.todosList
              }
            , Cmd.none
            )

        DeleteTodo id ->
            ( { model
                | todosList =
                    List.filter
                        (\a ->
                            a.id /= id
                        )
                        model.todosList
              }
            , Cmd.none
            )

        UpdateCurrentEdit edit ->
            ( { model | currentEdit = edit }, Cmd.none )

        SaveEdit ->
            if model.currentEdit /= "" then
                let
                    newTodo : Todo
                    newTodo =
                        { id = model.editId
                        , text = model.currentEdit
                        , complete = List.any (\a -> a.id == model.editId && a.complete) model.todosList
                        }
                in
                ( { model
                    | currentInput = ""
                    , todosList =
                        List.map
                            (\a ->
                                if a.id == model.editId then
                                    newTodo

                                else
                                    a
                            )
                            model.todosList
                    , editId = -1
                  }
                , Cmd.none
                )

            else
                ( model, Cmd.none )

        CancelEdit ->
            ( { model | currentEdit = "", editId = -1 }, Cmd.none )

        InitiateEdit newEditId editString ->
            ( { model | editId = newEditId, currentEdit = editString }, Cmd.none )

        KeyDownInEdit code ->
            if code == 13 then
                -- Enter key - save
                update SaveEdit model

            else if code == 27 then
                -- Escape key - cancel
                update CancelEdit model

            else
                ( model, Cmd.none )

        SetFilter filter ->
            ( { model | currentFilter = filter }, Cmd.none )

        ClearCompleted ->
            ( { model
                | todosList = List.filter (\todo -> not todo.complete) model.todosList
              }
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    div []
        [ input
            [ placeholder "Enter a Todo"
            , value model.currentInput
            , onInput UpdateInput
            ]
            []
        , button [ onClick AddTodo ] [ text "+" ]
        , viewList model
        , filterButton model All "All"
        , filterButton model Active "Active"
        , filterButton model Complete "Complete"
        , div [] [ text (String.fromInt (countActive model.todosList) ++ " items left") ]
        ]


viewList : Model -> Html Msg
viewList model =
    div []
        (model.todosList
            |> List.filter (shouldShowTodo model.currentFilter)
            |> List.map (todoItemToHtml model)
        )


todoItemToHtml : Model -> Todo -> Html Msg
todoItemToHtml model todo =
    if todo.id /= model.editId then
        div [ onDoubleClick (InitiateEdit todo.id todo.text) ]
            [ text (String.fromInt todo.id)
            , input
                [ type_ "checkbox"
                , checked todo.complete
                , onClick (ToggleComplete todo.id)
                ]
                []
            , text todo.text
            , button [ onClick (DeleteTodo todo.id) ] [ text "-" ]
            ]

    else
        div []
            [ text (String.fromInt todo.id)
            , input
                [ type_ "checkbox"
                , checked todo.complete
                , onClick (ToggleComplete todo.id)
                , disabled True
                ]
                []
            , input
                [ value model.currentEdit
                , onInput UpdateCurrentEdit
                , onKeyDownCode KeyDownInEdit
                ]
                []
            , button [ onClick SaveEdit ] [ text "Save" ]
            , button [ onClick CancelEdit ] [ text "Cancel" ]
            ]


toggleCompleteFlag : Todo -> Todo
toggleCompleteFlag todo =
    { id = todo.id, complete = not todo.complete, text = todo.text }


shouldShowTodo : Filter -> Todo -> Bool
shouldShowTodo filter todo =
    case filter of
        All ->
            True

        -- Show all todos
        Active ->
            not todo.complete

        -- Show only incomplete
        Complete ->
            todo.complete



-- Show only completed


filterButton : Model -> Filter -> String -> Html Msg
filterButton model filter string =
    button
        [ onClick (SetFilter filter)
        , style "background-color"
            (if model.currentFilter == filter then
                "yellow"

             else
                "white"
            )
        ]
        [ text string ]



-- Custom event handler for keydown


onKeyDownCode : (Int -> msg) -> Html.Attribute msg
onKeyDownCode tagger =
    on "keydown" (Decode.map tagger (Decode.field "keyCode" Decode.int))


countActive : List Todo -> Int
countActive todos =
    todos
        |> List.filter (\todo -> not todo.complete)
        |> List.length


encodeState : Model -> Encode.Value
encodeState model =
    Encode.object
        [ ( "nextId", Encode.int model.nextId )
        , ( "Todos", encodeTodos model.todosList )
        ]


encodeTodos : List Todo -> Encode.Value
encodeTodos todos =
    Encode.list encodeTodo todos


encodeTodo : Todo -> Encode.Value
encodeTodo todo =
    Encode.object
        [ ( "id", Encode.int todo.id )
        , ( "text", Encode.string todo.text )
        , ( "complete", Encode.bool todo.complete )
        ]


createTodo : Int -> String -> Bool -> Todo
createTodo id text complete =
    { id = id, text = text, complete = complete }


setTodos : List Todo -> Model -> Model
setTodos todos model =
    let
        maxId = List.maximum (List.map .id todos) |> Maybe.withDefault 0
    in
    { model
    | todosList = todos
    , nextId = maxId + 1  -- Set nextId to be one more than highest existing ID
    }
