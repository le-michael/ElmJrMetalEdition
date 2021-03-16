module ThreeDee exposing (..)

import Base exposing (..)
import API3D exposing (..)

-- Rotation needed for ArcBallCamera (there's already a default rotation)
-- Scene background colour
-- no need for maxDistance and minDistance 

-- RGB: Values between 0 and 1 (Had it between 0 and 255 as integers previously)

-- sphere (and all shapes) starts with a default
myShapes : Float -> List Shape
myShapes time =
    [ sphere |> color (rgb 1.0 1 1) |> move (0, 2.25, 0) |> scaleAll 0.5 -- scale 0.5 (move (0, 2.25, 0) sphere)
    , sphere |> color (rgb 1 1 1) |> move (0, 1.25, 0) |> scaleAll 0.75
    , sphere |> color (rgb 1 1 1)
    -- eyeballs
    , sphere |> color (rgb 0 0 0) |> scaleAll 0.075 |> move (-0.3, 2.25, 0.45)
    , sphere |> color (rgb 0 0 0) |> scaleAll 0.075 |> move (0.3, 2.25, 0.45)
    -- nose
    , capsule |> color (rgb (252/255) (174/255) (101/255)) |> rotate (90, 0, 0) |> scaleAll 0.1 |> move (0, 2.15, 0.5)
    -- hat
    , cylinder |> color (rgb 0.1 0.1 0.1) |> scale (0.35, 0.02, 0.35) |> move (0, 2.70, 0) --rim
    , cylinder |> color (rgb 0.1 0.1 0.1) |> scale (0.25, 0.2, 0.25) |> move (0, 2.90, 0) --top
    -- arm
    , cylinder |> color (rgb (150/255) (70/255) 0) |> scale (0.05, 0.8, 0.05) |> move (-0.55, 1.65, 0) |> rotate (0, 0, (45-15)+(15*sin (time * 8)))
    , cylinder |> color (rgb (150/255) (70/255) 0) |> scale (0.05, 0.8, 0.05) |> move (-0.67, 1.3, 0) |> rotate (0, 0, 35)
    ]

lights =
    [ DirectionalLight (RGB 0.6 0.6 0.6) (1, 2, 2) (RGB 0.1 0.1 0.1)
    , AmbientLight (RGB 1 1 1) 0.5
    ]

scene = viewWithTimeAndCamera (ArcballCamera 5 (0, -1, 0) Nothing Nothing) (RGB 1 1 1) lights myShapes

-- Shapes have smooth intensity
-- scale (x, y, z) instead of X, Y, Z
-- same thing for rotate?
-- standardize degrees

