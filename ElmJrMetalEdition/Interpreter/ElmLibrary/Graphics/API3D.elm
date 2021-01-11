module API3D exposing (..)

import Base exposing (..)

{-| This API exposes 3D shapes and functions to work with the created shapes

# Stencils

@docs ngon, sphere, cube, cuboid, cone, cylinder

# Creating Shapes from Stencils

@docs filled

# Grouping Shapes

@docs group

# Transformations

@docs move, rotate, rotateX, rotateY, rotateZ, scale, scaleX, scaleY, scaleZ


-}

ngon : Int -> Float -> Stencil
ngon n r =
    Polygon n r

sphere : Float -> Stencil
sphere r = Sphere r

cube : Float -> Stencil
cube l = Cuboid l l l

cuboid : Float -> Float -> Float -> Stencil
cuboid l w h = Cuboid l w h

cone : Float -> Float -> Stencil
cone r h = Cone r h

cylinder : Float -> Float -> Stencil
cylinder r h = Cylinder r h

move : ( Float, Float, Float ) -> Shape -> Shape
move disp shape =
    ApTransform (Translate disp) shape

-- Is the rotation in degrees or radians
-- The original API does it in radians
rotate : Float -> Float -> Float -> Shape -> Shape
rotate rx ry rz shape =
    ApTransform (Rotate3D rx ry rz) shape

rotateX : Float -> Shape -> Shape
rotateX rx shape = rotate rx 1 1 shape

rotateY : Float -> Shape -> Shape
rotateY ry shape = rotate 1 ry 1 shape

rotateZ : Float -> Shape -> Shape
rotateZ rz shape = rotate 1 1 rz shape

scale : Float -> Shape -> Shape
scale s shape =
    ApTransform (Scale s s s) shape

scaleX : Float -> Shape -> Shape
scaleX s shape =
    ApTransform (Scale s 1 1) shape

scaleY : Float -> Shape -> Shape
scaleY s shape =
    ApTransform (Scale 1 s 1) shape

scaleZ : Float -> Shape -> Shape
scaleZ s shape =
    ApTransform (Scale 1 1 s) shape
