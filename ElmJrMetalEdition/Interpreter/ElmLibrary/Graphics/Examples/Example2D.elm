module Example2D exposing (..)

import API2D exposing (..)
import Base exposing (viewWithTime, red, blue)

-- Note: We'll have to expose the correct things from Base so that users
-- can just do a (..) import

myScene = viewWithTime myShapes

myShapes time =
    [ myMovingCircle time
    , myRotatingTriangle time
    ]

myMovingCircle time =
    circle 10
        |> filled red
        |> move (time, -time)

myRotatingTriangle time =
    triangle 5
        |> filled blue
        |> rotate (sin (degrees time))
