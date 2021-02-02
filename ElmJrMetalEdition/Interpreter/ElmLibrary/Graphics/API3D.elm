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

ngon : Int -> Stencil
ngon n =
    Polygon n

sphere : Stencil
sphere = Sphere

cube : Stencil
cube = Cube

cone : Stencil
cone = Cone

cylinder : Stencil
cylinder = Cylinder

capsule : Stencil
capsule = Capsule

move : ( Float, Float, Float ) -> Shape -> Shape
move disp shape =
    ApTransform (Translate disp) shape

-- Is the rotation in degrees or radians
-- The original API does it in radians
rotate : (Float, Float, Float) -> Shape -> Shape
rotate r shape =
    ApTransform (Rotate3D r) shape

rotateAll : Float -> Shape -> Shape
rotateAll r shape = rotate (r, r, r) shape

scale : (Float, Float, Float) -> Shape -> Shape
scale s shape =
    ApTransform (Scale s) shape

scaleAll : Float -> Shape -> Shape
scaleAll s shape =
    scale (s, s, s) shape

group : List Shape -> Shape
group shapes = Group shapes