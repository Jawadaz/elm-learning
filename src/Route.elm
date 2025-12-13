module Route exposing (Route(..), fromUrl)

import Url exposing (Url)
import Url.Parser as Parser exposing (Parser, oneOf, s)



-- ROUTES


type Route
    = Home
    | Counter
    | Github
    | Canvas
    | Todo
    | D3Chart



-- PARSER


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Counter (s "counter")
        , Parser.map Github (s "github")
        , Parser.map Canvas (s "canvas")
        , Parser.map Todo (s "todo")
        , Parser.map D3Chart (s "d3chart")
        ]



-- PUBLIC HELPERS


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url
