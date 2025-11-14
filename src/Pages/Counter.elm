module Pages.Counter exposing (Model, Msg, init, update, view)

import Html exposing (Html, button, div, text, input, h2, p)
import Html.Attributes exposing (placeholder, value, style)
import Html.Events exposing (onClick, onInput)
import Random
import Time
import Task


-- MODEL

type alias Model =
    { count: Int
    , totalClicks: Int
    , inputValue: String
    , history: List String
    , historyFilter: String
    , backgroundColor: String
    , isModalOpen : Bool        -- NEW: Is modal showing?
    , modalInputValue : String  -- NEW: Value being typed in modal
    }

init : (Model, Cmd Msg)
init =
    ( { count = 0
      , totalClicks = 0
      , inputValue = ""
      , history = []
      , historyFilter = ""
      , backgroundColor = "rgb(123,45,200)"
      , isModalOpen = False
      , modalInputValue = ""
      }
    , Cmd.none
    )


-- UPDATE

type Msg
    = Increment Int
    | Decrement Int
    | IncrementInputValue
    | DecrementInputValue
    | Reset
    | UpdateInput String
    | HistoryFilter String
    | GenerateRandom
    | ReceiveRandom Int
    | RollDice
    | ReceiveDiceRoll (Int,Int)
    | GenerateRandomColor
    | RandomColorGenerated (Int,Int,Int)
    | GetCurrentTime
    | ReceiveTime Time.Posix
    | RandomizeEverything
    | OpenModal             -- NEW: User clicked button to open modal
    | CloseModal            -- NEW: User clicked Cancel or X
    | UpdateModalInput String  -- NEW: User typing in modal input
    | SaveModal             -- NEW: User clicked Save

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Increment n ->
            let
                newCount = model.count + n
                newClicks = model.totalClicks + 1
                newHistory = ("Increment by " ++ String.fromInt n) :: model.history
            in
                ({model | count = newCount, totalClicks = newClicks, history = newHistory}, Cmd.none)

        Decrement n ->
             let
                newCount = model.count - n
                newClicks = model.totalClicks + 1
                newHistory = ("Decrement by " ++ String.fromInt n) :: model.history
            in
                ({model | count = newCount, totalClicks = newClicks, history = newHistory}, Cmd.none)

        Reset ->
            ({model | count = 0, totalClicks = 0, history = "Reset "::model.history}, Cmd.none)

        UpdateInput str ->
            ({model | inputValue = str}, Cmd.none)

        IncrementInputValue ->
            case String.toInt model.inputValue of
                Just n ->
                    ({model | count = model.count + n, totalClicks = model.totalClicks + 1, history = ("Increment by "++model.inputValue)::model.history}
                    , Cmd.none)
                Nothing ->
                    (model, Cmd.none)

        DecrementInputValue ->
            case String.toInt model.inputValue of
                Just n ->
                    ({model | count = model.count - n, totalClicks = model.totalClicks + 1,history = ("Decrement by "++model.inputValue)::model.history}
                    , Cmd.none)
                Nothing ->
                    (model, Cmd.none)

        HistoryFilter str ->
            ({model|historyFilter = str}, Cmd.none)

        GenerateRandom ->
              ( model
              , Random.generate ReceiveRandom (Random.int 1 100)
              )

        ReceiveRandom randomNum ->
              ( {model | count = randomNum, history = "ReceiveRandom"::model.history}
              , Cmd.none
              )

        RollDice ->
            (model,
            Random.generate ReceiveDiceRoll (Random.pair (Random.int 1 6) (Random.int 1 6)))

        ReceiveDiceRoll (die1,die2)->
            ({model | count = die1 + die2}
            ,Cmd.none)

        GenerateRandomColor ->
            (model,
            Random.generate RandomColorGenerated
                (Random.map3 (\r g b -> (r, g, b))
                    (Random.int 0 255)
                    (Random.int 0 255)
                    (Random.int 0 255)))

        RandomColorGenerated (r,g,b) ->
            ({model|backgroundColor = toRgbString r g b, history = "RandomColorGenerated"::model.history}
            ,Cmd.none)

        GetCurrentTime ->
             ( model
            , Task.perform ReceiveTime Time.now
             )

        ReceiveTime posixTime ->
            let
                milliseconds =
                  posixTime
                    |> Time.posixToMillis
                    |> (\ms -> ms // 1000)
            in
                ( {model | count = milliseconds,history = "Time"::model.history}
                , Cmd.none
                 )

        RandomizeEverything ->
             ( model
             , Cmd.batch
                  [ Random.generate ReceiveRandom (Random.int 1 100)
                  , Random.generate RandomColorGenerated
                 (Random.map3 (\r g b -> (r, g, b))
                     (Random.int 0 255)
                      (Random.int 0 255)
                   (Random.int 0 255))
            , Task.perform ReceiveTime Time.now
              ]
          )

        OpenModal ->
            -- YOUR TASK: Open the modal and set modalInputValue to current count
            -- Hint: Convert count to String with String.fromInt
            ({model|isModalOpen = True, modalInputValue = String.fromInt model.count}, Cmd.none)

        CloseModal ->
            -- YOUR TASK: Close the modal (don't change count)
            ({model| isModalOpen = False}, Cmd.none)

        UpdateModalInput value ->
            -- YOUR TASK: Update modalInputValue as user types
            ({model|modalInputValue = value}, Cmd.none)

        SaveModal ->
            case String.toInt model.modalInputValue of
                Just newCount ->
                    ( { model
                      | count = newCount
                      , isModalOpen = False
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( { model | isModalOpen = False }
                    , Cmd.none
                    )



-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ button [ onClick (Decrement 1) ] [ text "-" ]
        , button [ onClick (Decrement 5) ] [ text "-5" ]
        , button [ onClick (DecrementInputValue) ] [ text ("-"++model.inputValue) ]
        , div [] [ text ("Count:  " ++ String.fromInt model.count) ]
        , div [] [ text ("Clicks: " ++ String.fromInt model.totalClicks) ]
        , input
            [ placeholder "Enter amount"
             , value model.inputValue
             , onInput UpdateInput
              ]
             []
        , button [ onClick (Increment 1) ] [ text "+" ]
        , button [ onClick (Increment 5) ] [ text "+5" ]
        , button [ onClick (IncrementInputValue) ] [ text ("+"++model.inputValue) ]
        , button [ onClick Reset ] [ text "Reset" ]
        , div[] [
            div[] [text "History:"]
            , div [] (List.map historyItemToHtml model.history)
        ]
        , div [] [
                        div[] [text "History Filters:"]

        , button [ onClick (HistoryFilter "Increment") ] [ text "Increment" ]
        , button [ onClick (HistoryFilter "Decrement") ] [ text "Decrement" ]
        , button [ onClick (HistoryFilter "Reset") ] [ text ("Reset") ]
        , button [ onClick (HistoryFilter "") ] [ text ("None") ]
        ]
        , div[] [
            div[] [text "Filtered History:"]
            , div [] (model.history
                      |> filterHistory model.historyFilter
                      |> List.map historyItemToHtml)
        ]
        ,button [ onClick GenerateRandom ] [ text "Random!" ]
        ,button [ onClick RollDice ] [ text "Roll Dice!" ]
        , div [ style "background-color" model.backgroundColor, style "padding" "20px" ]
        [ text "Current color" ]
        ,button [ onClick GenerateRandomColor ] [ text "Generate Color!" ]
        ,button [onClick GetCurrentTime] [text "Get Time"]
        ,button [onClick RandomizeEverything] [text "Randomizer"]
        , button [ onClick OpenModal, style "margin-left" "20px" ]
        [ text "Set Custom Value" ]
        , if model.isModalOpen then
                viewModal model
            else
                text ""
        ]


-- HELPERS

historyItemToHtml : String -> Html Msg
historyItemToHtml action =
    div[] [text action]

filterHistory : String -> List String -> List String
filterHistory filter history =
    history
        |> List.filter (\action -> String.contains filter action)

toRgbString : Int -> Int -> Int -> String
toRgbString r g b =
      "rgb(" ++ String.fromInt r ++ ", " ++ String.fromInt g ++ ", " ++ String.fromInt b ++ ")"

viewModal : Model -> Html Msg
viewModal model =
      div
          [ -- Overlay (darkens background)
            style "position" "fixed"
          , style "top" "0"
          , style "left" "0"
          , style "width" "100%"
          , style "height" "100%"
          , style "background-color" "rgba(0, 0, 0, 0.5)"
          , style "display" "flex"
          , style "align-items" "center"
          , style "justify-content" "center"
          ]
          [ div
              [ -- Modal box
                style "background-color" "white"
              , style "padding" "30px"
              , style "border-radius" "8px"
              , style "box-shadow" "0 4px 6px rgba(0, 0, 0, 0.1)"
              ]
              [ h2 [] [ text "Set Counter Value" ]
              , p [] [ text "Enter a new value for the counter:" ]
              , input
                  [ placeholder "Enter number"
                  , value model.modalInputValue
                  , onInput UpdateModalInput
                  , style "padding" "10px"
                  , style "width" "200px"
                  , style "margin-bottom" "20px"
                  ]
                  []
              , div []
                  [ button
                      [ onClick SaveModal
                      , style "padding" "10px 20px"
                      , style "margin-right" "10px"
                      , style "background-color" "#4CAF50"
                      , style "color" "white"
                      , style "border" "none"
                      , style "cursor" "pointer"
                      ]
                      [ text "Save" ]
                  , button
                      [ onClick CloseModal
                      , style "padding" "10px 20px"
                      , style "background-color" "#f44336"
                      , style "color" "white"
                      , style "border" "none"
                      , style "cursor" "pointer"
                      ]
                      [ text "Cancel" ]
                  ]
              ]
          ]