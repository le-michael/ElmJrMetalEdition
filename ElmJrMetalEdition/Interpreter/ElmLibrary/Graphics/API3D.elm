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

ngon : Int -> Shape
ngon n =
    BaseStencil (Polygon n)

sphere : Shape
sphere = BaseStencil Sphere

cube : Shape
cube = BaseStencil Cube

cone : Shape
cone = BaseStencil Cone

cylinder : Shape
cylinder = BaseStencil Cylinder

capsule : Shape
capsule = BaseStencil Capsule

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
