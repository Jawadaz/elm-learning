module Pages.D3Chart exposing (Model, Msg, init, subscriptions, update, view)

import Html exposing (Html, button, div, input, text)
import Html.Attributes exposing (placeholder, type_, value)
import Html.Events exposing (onClick, onInput)


type alias DataPoint = {
    label : String
    , value : Int
  }

type alias Model = {
    dataPoints : List DataPoint
    , currentLabel : String
    , currentValue : String
    , clickedBar : Maybe String
    }


type Msg 
    = UpdateLabel String
    | UpdateValue String
    | AddDataPoint
    | RemoveDataPoint String
    | BarClicked String


init : ( Model, Cmd Msg )
init =
 ( { dataPoints = [], currentLabel = "", currentValue = "" , clickedBar = Nothing }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
      -- TODO: Handle all the messages
      -- Hint: AddDataPoint should parse currentValue as Int and create new DataPoint
      case msg of
        UpdateLabel label ->
            ({model|currentLabel = label}, Cmd.none)
        UpdateValue value ->
            ({model|currentValue = value}, Cmd.none)
        AddDataPoint ->
            let 
                newDataPoint : DataPoint
                newDataPoint = ({label = model.currentLabel, value = String.toInt model.currentValue |> Maybe.withDefault 0})
            in
                ({model | dataPoints = newDataPoint :: model.dataPoints}, Cmd.none)
        RemoveDataPoint label ->
            ({model|dataPoints = model.dataPoints |> 
                        List.filter 
                            (\a->
                                a.label /= label) }, Cmd.none)
        BarClicked label ->
            ({model | clickedBar = Just label}, Cmd.none)


view : Model -> Html Msg
view model =
 div []
        [ input
            [ placeholder "Enter A Label"
            , value model.currentLabel
            , onInput UpdateLabel
            ]
            []
        , input
            [ placeholder "Enter A Value"
            , value model.currentValue
            , onInput UpdateValue
            ]
            []
        , button [ onClick AddDataPoint ] [ text "+" ]
        , div [] (List.map dataPointToHtml model.dataPoints)
        , div []
            [text ("Last Clicked " ++ (model.clickedBar |> Maybe.withDefault ""))]
        ]

dataPointToHtml : DataPoint -> Html Msg
dataPointToHtml dataPoint =
    div []
    [text (dataPoint.label ++ " " ++ String.fromInt dataPoint.value)
     , button [ onClick (RemoveDataPoint dataPoint.label)] [ text "-" ]
    ]
   


subscriptions : Model -> Sub Msg
subscriptions model =
      -- TODO: We'll add the incoming port subscription later
      Sub.none