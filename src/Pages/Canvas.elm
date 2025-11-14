module Pages.Canvas exposing (Model, Msg, init, subscriptions, update, view)

import Browser.Events
import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (style)
import Json.Decode as Decode
import Svg exposing (circle, svg)
import Svg.Attributes exposing (cx, cy, fill, height, r, viewBox, width)
import Time



-- MODEL


type alias Model =
    { seconds : Int
    , ballX : Float
    , velocityX : Float
    }


init : ( Model, Cmd Msg )
init =
    ( { seconds = 0, ballX = 0, velocityX = 3 }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | KeyPressed String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick _ ->
            let
                newX =
                    model.ballX + model.velocityX

                newVelocity =
                    if newX >= 780 then
                        -- Hit right wall, reverse
                        abs model.velocityX * -1

                    else if newX <= 20 then
                        -- Hit left wall, reverse
                        abs model.velocityX

                    else
                        -- No collision, keep velocity
                        model.velocityX
            in
            ( { model
                | seconds = model.seconds + 1
                , ballX = newX
                , velocityX = newVelocity
              }
            , Cmd.none
            )

        KeyPressed key ->
            case key of
                "ArrowLeft" ->
                    -- Move ball left (decrease X)
                    ( { model | ballX = model.ballX - 20 }
                    , Cmd.none
                    )

                "ArrowRight" ->
                    -- Move ball right (increase X)
                    ( { model | ballX = model.ballX + 20 }
                    , Cmd.none
                    )

                _ ->
                    -- Ignore other keys
                    ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ style "padding" "40px" ]
        [ h1 [] [ text "Bouncing Ball Animation" ]
        , div [] [ text ("Time: " ++ String.fromInt model.seconds ++ "s") ]
        , svg
            [ width "800"
            , height "400"
            , viewBox "0 0 800 400"
            , style "border" "2px solid black"
            , style "background-color" "#f0f0f0"
            ]
            [ circle
                [ cx (String.fromFloat model.ballX)
                , cy "200" -- Middle of height (400/2)
                , r "20" -- Radius 20 pixels
                , fill "red"
                ]
                []
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Time.every 16 Tick
        , Browser.Events.onKeyDown keyDecoder
        ]



-- Decode which key was pressed


keyDecoder : Decode.Decoder Msg
keyDecoder =
    Decode.map KeyPressed (Decode.field "key" Decode.string)
