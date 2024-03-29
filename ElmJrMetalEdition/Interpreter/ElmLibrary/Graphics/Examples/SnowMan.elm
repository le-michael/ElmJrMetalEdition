hat : Shape
hat = group [
      cylinder
        |> color (rgb 0.1 0.1 0.1)
        |> scale (0.35, 0.02, 0.35)
        |> move (0, 2.70, 0)
    , cylinder
        |> color (rgb 0.1 0.1 0.1)
        |> scale (0.25, 0.2, 0.25)
        |> move (0, 2.90, 0)
    ]

myShapes : Float -> List Shape
myShapes time =
    [ sphere
        |> color (rgb 1 1 1)
        |> move (0, 2.25, 0)
        |> scaleAll 0.5
    , sphere
        |> color (rgb 1 1 1)
        |> move (0, 1.25, 0)
        |> scaleAll 0.75
    , sphere
        |> color (rgb 1 1 1)
    , sphere
        |> color (rgb 0 0 0)
        |> scaleAll 0.075
        |> move (-0.3, 2.25, 0.45)
    , sphere
        |> color (rgb 0 0 0)
        |> scaleAll 0.075
        |> move (0.3, 2.25, 0.45)
    , capsule
        |> color (rgb (252/255) (174/255) (101/255))
        |> rotate (90, 0, 0)
        |> scaleAll 0.1
        |> move (0, 2.15, 0.5)
    , hat
        |> scaleAll 0.75
        |> rotate (0, 0, degToRad (0))
        |> move (0, 0.7, 0)
    , cylinder
        |> color (rgb (150/255) (70/255) 0)
        |> scale (0.05, 0.8, 0.05)
        |> move (-0.55, 1.65, 0)
        |> rotate (0, 0, degToRad (45-15)+(degToRad (15) *sin (time * 8 * (180 * 3.14))))
    , cylinder
        |> color (rgb (150/255) (70/255) 0)
        |> scale (0.05, 0.8, 0.05)
        |> move (0.67, 1.3, 0)
        |> rotate (0, 0, degToRad (35))
    ]

lights =
    [ DirectionalLight Nothing (RGB (0.6, 0.6, 0.6)) (1, 2, 2) (RGB (0.1, 0.1, 0.1))
    , AmbientLight Nothing (RGB (1, 1, 1)) 0.5
    ]

scene = viewWithTimeAndCamera (ArcballCamera 5 (0, -1, 0) Nothing Nothing) (RGB (1, 1, 1)) (\f -> lights) myShapes
