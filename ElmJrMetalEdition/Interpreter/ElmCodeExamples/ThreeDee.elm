module ThreeDee exposing (..)

-- Rotation needed for ArcBallCamera (there's already a default rotation)
-- Scene background colour
-- no need for maxDistance and minDistance 

-- RGB: Values between 0 and 1 (Had it between 0 and 255 as integers previously)

type Light =
    DirectionalLight RGB {- light colour -} (Float, Float, Float) {- position/direction of vector -} RGB {- specular colour -}
    | AmbientLight RGB Float {- float between 0 and 1 -}

scene = viewWithTimeAndCamera (ArcBallCamera 5 (0, -1, 0) {- sceneColour : RGBA -} {- rotation : Float -}) lights myShapes 

lights =
    [ DirectionalLight (RGB 0.6 0.6 0.6) (1, 2, 2) (RGB 0.1 0.1 0.1)
    , AmbientLight (RGB 1 1 1) 0.5
    ]

-- sphere (and all shapes) starts with a default
myShapes time =
    [ sphere |> move (0, 2.25, 0) |> scale 0.5 
    , sphere |> move (0, 1.25, 0) |> scale 0.75
    , sphere
    -- eyeballs
    , sphere |> scale 0.075 |> move (-0.3, 2.25, 0.45) |> rgb 0 0 0
    , sphere |> scale 0.075 |> move (0.3, 2.25, 0.45) |> rgb 0 0 0
    -- nose
    , capsule |> rotate (90, 0, 0) |> scale 0.1 |> move (0, 2.15, 0.5) |> rgb 252/255 174/255 101/255
    -- hat
    , cylinder |> scale (0.35, 0.02, 0.35) |> move (0, 2.70, 0) |> rgb 0.1 0.1 0.1 --rim
    , cylinder |> scale (0.25, 0.02, 0.25) |> move (0, 2.90, 0) |> rgb 0.1 0.1 0.1 --top
    -- arm
    , cylinder |> scale (0.05, 0.8, 0.05) |> move (-0.55, 1.65, 0) |> rotate (0, 0, (45-15)+(15*sin (time * 8)))
    ]
-- Shapes have smooth intensity
-- scale (x, y, z) instead of X, Y, Z
-- same thing for rotate?
-- standardize degrees
