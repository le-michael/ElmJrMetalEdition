myShapes : Float -> List Shape
myShapes time =
    [ sphere
        |> color (rgb (1 1 1))
        |> move (0, 2.25, 0)
        |> scaleAll 0.5
    ]

lights =
    [ DirectionalLight (RGB 0.6 0.6 0.6) (1, 2, 2) (RGB 0.1 0.1 0.1)
    , AmbientLight (RGB 1 1 1) 0.5
    ]

scene = viewWithTimeAndCamera (ArcballCamera 5 (0, -1, 0) Nothing Nothing) (RGB 1 1 1) lights myShapes
