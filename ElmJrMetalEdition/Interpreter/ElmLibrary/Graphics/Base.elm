module Base exposing (..)

{-
A more prudent import list will be done at a later stage,
when the compiler supports it

We should be hiding the following things from being imported:
- Stencil
- Color
- Camera (to be replaced with smart constructors)
- Scene
- Shape
- ssc, ssa, clamp (to be replaced with the Core implementation)
-}

-- Primitive type representing the shape to be drawn. All in 3D space
type Stencil
    = Sphere
    | Cube
    | Polygon Int
    | Cone
    | Cylinder
    | Capsule
    | Model String

type Transform
    = Translate ( Float, Float, Float)
    | Rotate2D Float
    | Rotate3D (Float, Float, Float)
    | Scale (Float, Float, Float)

type Color
    = RGB (Float, Float, Float)

{- Can add this back in when parsing is better at handling whitespace
type Light
    = DirectionalLight
      Color -- light colour
      (Float, Float, Float) -- position/direction of vector
      Color -- specular colour
    | AmbientLight Color Float -- float between 0 and 1
-}
type Light
    = DirectionalLight (Maybe Float) Color (Float, Float, Float) Color
    | AmbientLight (Maybe Float) Color Float
    | Point (Maybe Float) Color (Float, Float, Float) (Float, Float, Float) -- color, position, attenuation
    | Spotlight (Maybe Float) Color (Float, Float, Float) (Float, Float, Float) Float (Float, Float, Float) Float

{- Can add this back in when parsing is better at handling whitespace
type Camera
    = Camera Transform
    | ArcballCamera
      Float -- distance
      ( Float, Float, Float ) -- target
      (Maybe Color) -- sceneColor, Nothing is default
      (Maybe (Float, Float, Float)) -- rotation, Nothing is default
-}
type Camera
    = Camera Transform
    | ArcballCamera Float ( Float, Float, Float ) (Maybe Color) (Maybe (Float, Float, Float))

type Shape
    = Inked (List Color) Shape -- Base constructor: apply colour to a Stencil
    | ApTransform Transform Shape -- Apply a transform to an already defined shape
    | Group (List Shape)
    | BaseStencil Stencil
    | Smooth Float Shape
    | Shininess Float Shape

type Scene
    = Scene Camera Color (List Light) (List Shape)
    | SceneWithTime Camera Color (Float -> List Light) (Float -> List Shape)


defaultCamera : Camera
defaultCamera = Camera (Translate (0, 0, 0))

-- The default scene initializer
view : Color -> List Light -> List Shape -> Scene
view c lights shapes = Scene defaultCamera c lights shapes

-- If the camera is to be used, this function should be called instead
-- Only direct manipulation to the Camera constructor is supported for now
viewWithCamera : Camera -> Color -> List Light -> List Shape -> Scene
viewWithCamera camera c lights shapes = Scene camera c lights shapes

-- Creating a scene with a time property requires this initializer
-- The time is passed in as an argument to the scene
viewWithTime : Color -> (Float -> List Light) -> (Float -> List Shape) -> Scene
viewWithTime c lights shapes = SceneWithTime defaultCamera c lights shapes

viewWithTimeAndCamera : Camera -> Color -> (Float -> List Light) -> (Float -> List Shape) -> Scene
viewWithTimeAndCamera camera c lights shapes = SceneWithTime camera c lights shapes

smooth : Float -> Shape -> Shape
smooth f s = Smooth f s

shininess : Float -> Shape -> Shape
shininess f s = Shininess f s

color : Color -> Shape -> Shape
color c stencil =
    Inked [c] stencil

colors : List Color -> Shape -> Shape
colors cs stencil =
    Inked cs stencil

model : String -> Shape
model s = BaseStencil (Model s)

-- group shapes
group : List Shape -> Shape
group shapes = Group shapes

-- The `clamp` function is in the Elm Core library
-- But it is here as we do not use the library yet
clamp : number -> number -> number -> number
clamp low high number =
    (if number < low then
        low
    else if number > high then
        high
    else
        number)

ssc : number -> number
ssc n =
    clamp 0 255 n

ssa : Float -> Float
ssa n =
    clamp 0 1 n

rgb : Float -> Float -> Float -> Color
rgb r g b = RGB (ssa r, ssa g, ssa b)

pi : Float
pi = 3.141592653589793

-- deg to rad
degToRad : Float -> Float
degToRad n = n * pi/180

-- rad to deg
radToDeg : Float -> Float
radToDeg n = n * 180/pi

-- Default available colors

{-| -}
pink : Color
pink =
    RGB (1, 105/255, 180/255)

{-| -}
hotPink : Color
hotPink =
    RGB (1, 0, 66/255)


{-| -}
lightRed : Color
lightRed =
    RGB (239/255, 41/255, 41/255)


{-| -}
red : Color
red =
    RGB (204/255, 0, 0)


{-| -}
darkRed : Color
darkRed =
    RGB (164/255, 0, 0)


{-| -}
lightOrange : Color
lightOrange =
    RGB (252/255, 175/255, 62/255)


{-| -}
orange : Color
orange =
    RGB (245/255, 121/255, 0)


{-| -}
darkOrange : Color
darkOrange =
    RGB (206/255, 92/255, 0)


{-| -}
lightYellow : Color
lightYellow =
    RGB (1, 233/255, 79/255)


{-| -}
yellow : Color
yellow =
    RGB (237/255, 212/255, 0)


{-| -}
darkYellow : Color
darkYellow =
    RGB (196/255, 160/255, 0)


{-| -}
lightGreen : Color
lightGreen =
    RGB (138/255, 226/255, 52/255)


{-| -}
green : Color
green =
    RGB (115/255, 210/255, 22/255)


{-| -}
darkGreen : Color
darkGreen =
    RGB (78/255, 154/255, 6/255)


{-| -}
lightBlue : Color
lightBlue =
    RGB (114/255, 159/255, 207/255)


{-| -}
blue : Color
blue =
    RGB (52/255, 101/255, 164/255)


{-| -}
darkBlue : Color
darkBlue =
    RGB (32/255, 74/255, 135/255)


{-| -}
lightPurple : Color
lightPurple =
    RGB (173/255, 127/255, 168/255)


{-| -}
purple : Color
purple =
    RGB (117/255, 80/255, 123/255)


{-| -}
darkPurple : Color
darkPurple =
    RGB (92/255, 53/255, 102/255)


{-| -}
lightBrown : Color
lightBrown =
    RGB (233/255, 185/255, 110/255)


{-| -}
brown : Color
brown =
    RGB (193/255, 125/255, 17/255)


{-| -}
darkBrown : Color
darkBrown =
    RGB (143/255, 89/255, 2/255)


{-| -}
black : Color
black =
    RGB (0, 0, 0)


{-| -}
white : Color
white =
    RGB (1, 1, 1)


{-| -}
lightGrey : Color
lightGrey =
    RGB (238/255, 238/255, 236/255)


{-| -}
grey : Color
grey =
    RGB (211/255, 215/255, 207/255)


{-| -}
darkGrey : Color
darkGrey =
    RGB (186/255, 189/255, 182/255)


{-| -}
lightGray : Color
lightGray =
    RGB (238/255, 238/255, 236/255)


{-| -}
gray : Color
gray =
    RGB (211/255, 215/255, 207/255)


{-| -}
darkGray : Color
darkGray =
    RGB (186/255, 189/255, 182/255)


{-| -}
lightCharcoal : Color
lightCharcoal =
    RGB (136/255, 138/255, 133/255)


{-| -}
charcoal : Color
charcoal =
    RGB (85/255, 87/255, 83/255)


{-| -}
darkCharcoal : Color
darkCharcoal =
    RGB (46/255, 52/255, 54/255)


{-| -}
blank : Color
blank =
    RGB (0, 0, 0)
