module Pages.Home exposing (view)

import Html exposing (Html, div, h1, h2, p, ul, li, a, text)
import Html.Attributes exposing (href, style)


view : Html msg
view =
    div
        [ style "padding" "40px"
        , style "font-family" "Arial, sans-serif"
        ]
        [ h1 [] [ text "Elm Learning Project" ]
        , p [] [ text "Welcome! Choose a page to explore:" ]
        , ul []
            [ li []
                [ a [ href "/counter" ] [ text "Counter" ]
                , text " - Interactive counter with history and random features"
                ]
            , li []
                [ a [ href "/github" ] [ text "GitHub Repo Viewer" ]
                , text " - Fetch and display GitHub repositories (HTTP + JSON)"
                ]
            , li []
                [ a [ href "/canvas" ] [ text "Canvas Animation" ]
                , text " - Simple animation/game"
                ]
            ]
        , h2 [] [ text "What I've Learned So Far:" ]
        , ul []
            [ li [] [ text "Elm Architecture (Model-Update-View)" ]
            , li [] [ text "Immutability and pure functions" ]
            , li [] [ text "Custom types and pattern matching" ]
            , li [] [ text "Commands and side effects" ]
            , li [] [ text "Lists, Maybe types, and Records" ]
            , li [] [ text "Random generators and Tasks" ]
            ]
        ]
