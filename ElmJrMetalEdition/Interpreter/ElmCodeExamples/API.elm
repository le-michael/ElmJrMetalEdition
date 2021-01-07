module API exposing (..)

type Stencil
    = Circle Float Float
    | Rect Float Float
    | Polygon (List (Float, Float))

type Shape =
    Inked (Maybe Color) Stencil
    | Move (Float, Float) Shape
    | Rotate Float Shape
    | Scale Float Float Shape

type Color = RGBA Float Float Float Float

myShape =
    triangle 50
        |> filled red
        |> move (50, 50)

triangle = ngon 3

{-
-- This function uses reverse function application (<|) and
-- reverse function composition (<<), as well as Core
-- Elm functions. Uncomment and use this version
-- if the compiler supports these operators!
ngon : Int -> Float -> Stencil
ngon n r =
    Polygon <|
        List.map
            (ptOnCircle r (Basics.toFloat n) << Basics.toFloat)
            (List.range 0 n)

ptOnCircle : Float -> Float -> Float -> ( Float, Float )
ptOnCircle r n cn =
    let
        angle =
            turns (cn / n)
    in
    ( r * cos angle, r * sin angle )
-}

-- This is just a mock implementation
ngon : Int -> Float -> Stencil
ngon n r =
    if n == 3
        then Polygon [(0, 0), (10, 10), (0, 20)]
        else Polygon []
        
red : Color
red =
    RGBA 204 0 0 1

filled : Color -> Stencil -> Shape
filled color stencil =
    Inked (Just color) stencil

move : ( Float, Float ) -> Shape -> Shape
move disp shape =
    Move disp shape

