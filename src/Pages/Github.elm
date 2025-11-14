module Pages.Github exposing (Model, Msg, init, update, view)

import Html exposing (Html, div, h1, h2, p, text, input, button, ul, li, a)
import Html.Attributes exposing (style, placeholder, value, href, target)
import Html.Events exposing (onInput, onClick)
import Http
import Json.Decode as Decode exposing (Decoder, field, string, int, list, maybe)


-- MODEL

type alias Repo =
    { name : String
    , description : Maybe String
    , htmlUrl : String
    , stargazers_count : Int
    , language : Maybe String      -- NEW
    , forks_count : Int            -- NEW
    , created_at : String          -- NEW
    }

type RemoteData error value
    = NotAsked
    | Loading
    | Failure error
    | Success value

type alias Model =
    { username : String
    , repos : RemoteData Http.Error (List Repo)
    }

init : (Model, Cmd Msg)
init =
    ( { username = ""
      , repos = NotAsked
      }
    , Cmd.none
    )


-- UPDATE

type Msg
    = UpdateUsername String
    | FetchRepos
    | GotRepos (Result Http.Error (List Repo))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        UpdateUsername username ->
            ( { model | username = username }
            , Cmd.none
            )

        FetchRepos ->
            ( { model | repos = Loading }
            , fetchRepos model.username
            )

        GotRepos result ->
            case result of
                Ok repos ->
                    ( { model | repos = Success repos }
                    , Cmd.none
                    )

                Err error ->
                    ( { model | repos = Failure error }
                    , Cmd.none
                    )


-- HTTP

fetchRepos : String -> Cmd Msg
fetchRepos username =
    Http.get
        { url = "https://api.github.com/users/" ++ username ++ "/repos"
        , expect = Http.expectJson GotRepos reposDecoder
        }


-- JSON DECODERS

repoDecoder : Decoder Repo
repoDecoder =
    Decode.map7 Repo
        (field "name" string)
        (field "description" (maybe string))
        (field "html_url" string)
        (field "stargazers_count" int)
        (field "language" (maybe string))
        (field "forks_count" int)
        (field "created_at" string)

reposDecoder : Decoder (List Repo)
reposDecoder =
    list repoDecoder


-- VIEW

view : Model -> Html Msg
view model =
    div [ style "padding" "40px" ]
        [ h1 [] [ text "GitHub Repository Viewer" ]
        , p [] [ text "Enter a GitHub username to see their repositories:" ]
        , div []
            [ input
                [ placeholder "Enter GitHub username (e.g., evancz)"
                , value model.username
                , onInput UpdateUsername
                , style "padding" "10px"
                , style "margin-right" "10px"
                , style "width" "300px"
                ]
                []
            , button
                [ onClick FetchRepos
                , style "padding" "10px 20px"
                , style "cursor" "pointer"
                ]
                [ text "Fetch Repos" ]
            ]
        , viewRepos model.repos
        ]


viewRepos : RemoteData Http.Error (List Repo) -> Html Msg
viewRepos remoteData =
    case remoteData of
        NotAsked ->
            div [ style "margin-top" "20px" ]
                [ text "Enter a username and click 'Fetch Repos' to get started." ]

        Loading ->
            div [ style "margin-top" "20px" ]
                [ text "Loading repositories..." ]

        Failure error ->
            div [ style "margin-top" "20px", style "color" "red" ]
                [ text "Error: "
                , text (errorToString error)
                ]

        Success repos ->
            if List.isEmpty repos then
                div [ style "margin-top" "20px" ]
                    [ text "No repositories found." ]
            else
                div [ style "margin-top" "20px" ]
                    [ h2 [] [ text ("Found " ++ String.fromInt (List.length repos) ++ " repositories:") ]
                    , ul [] (List.map viewRepo repos)
                    ]


viewRepo : Repo -> Html Msg
viewRepo repo =
    li [ style "margin-bottom" "15px" ]
        [ a [ href repo.htmlUrl, target "_blank", style "font-weight" "bold" ]
            [ text repo.name ]
        , div [ style "color" "#f39c12", style "margin-top" "5px" ]
            [ text ("⭐ " ++ String.fromInt repo.stargazers_count ++ " stars") ]
        , div [ style "margin-top" "5px" ]
            [ text ("🍴 " ++ String.fromInt repo.forks_count ++ " forks | 📅 Created: " ++ repo.created_at) ]
        , case repo.language of
            Just lang ->
                div [ style "margin-top" "5px", style "color" "#3498db" ]
                    [ text ("💻 Language: " ++ lang) ]
            Nothing ->
                text ""
        , case repo.description of
            Just desc ->
                div [ style "margin-top" "5px" ] [ text desc ]
            Nothing ->
                div [ style "color" "#888", style "margin-top" "5px" ] [ text "(no description)" ]
        ]


errorToString : Http.Error -> String
errorToString error =
    case error of
        Http.BadUrl url ->
            "Invalid URL: " ++ url

        Http.Timeout ->
            "Request timed out"

        Http.NetworkError ->
            "Network error - check your connection"

        Http.BadStatus statusCode ->
            "Server returned error code: " ++ String.fromInt statusCode

        Http.BadBody message ->
            "Failed to decode response: " ++ message
