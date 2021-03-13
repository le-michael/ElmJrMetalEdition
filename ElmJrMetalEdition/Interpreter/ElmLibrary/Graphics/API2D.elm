module API2D exposing (..)

import Base exposing (..)

{-|
# Stencils

@docs ngon, triangle, circle

# Creating Shapes from Stencils

@docs filled

# Grouping Shapes

@docs group

# Transformations

@docs move, rotate, scale, scaleX, scaleY

-}


ngon : Int -> Stencil
ngon n =
    Polygon n

triangle = ngon 3

circle : Stencil
circle = Sphere


filled : Color -> Stencil -> Shape
filled color stencil =
    Inked [color] stencil

group : List Shape -> Shape
group shapes = Group shapes

-- Pattern matching used with let statement here
move : ( Float, Float ) -> Shape -> Shape
move disp shape =
    let
        (xt, yt) = disp
    in
    ApTransform (Translate (xt, yt, 1)) shape

-- Is the rotation in degrees or radians
-- The original API does it in radians
rotate : Float -> Shape -> Shape
rotate theta shape =
    ApTransform (Rotate2D theta) shape

scale : Float -> Shape -> Shape
scale s shape =
    ApTransform (Scale (s, s, 1)) shape

scaleX : Float -> Shape -> Shape
scaleX s shape =
    ApTransform (Scale (s, 1, 1)) shape

scaleY : Float -> Shape -> Shape
scaleY s shape =
    ApTransform (Scale (1, s, 1)) shape

{-
myScene = view [myShape]

myShape =
    triangle 50
        |> filled red
        |> move ( 50, 50 )

-}
