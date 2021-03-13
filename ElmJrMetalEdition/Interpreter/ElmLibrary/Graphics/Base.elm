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
    | Smooth Float Stencil
    | Shininess Float Stencil

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
    = DirectionalLight Color (Float, Float, Float) Color
    | AmbientLight Color Float
    | Point Color (Float, Float, Float) (Float, Float, Float) -- color, position, attenuation
    | Spotlight Color (Float, Float, Float) (Float, Float, Float) Float (Float, Float, Float) (Float, Float, Float)

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
    = Inked (List Color) Stencil -- Base constructor: apply colour to a Stencil
    | ApTransform Transform Shape -- Apply a transform to an already defined shape
    | Group (List Shape)

type Scene
    = Scene Camera Color (List Light) (List Shape)
    | SceneWithTime Camera Color (List Light) (Float -> List Shape)


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
viewWithTime : Color -> List Light -> (Float -> List Shape) -> Scene
viewWithTime c lights shapes = SceneWithTime defaultCamera c lights shapes

viewWithTimeAndCamera : Camera -> Color -> List Light -> (Float -> List Shape) -> Scene
viewWithTimeAndCamera camera c lights shapes = SceneWithTime camera c lights shapes

smooth : Float -> Stencil -> Stencil
smooth f s = Smooth f s

shininess : Float -> Stencil -> Stencil
shininess f s = Shininess f s

color : Color -> Stencil -> Shape
color c stencil =
    Inked [c] stencil

colorModel : List Color -> Stencil -> Shape
colorModel cs stencil =
    Inked cs stencil

model : String -> Stencil
model s = Model s

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
rgb r g b = RGB (ssa r, ssc g, ssc b)

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
    RGB (255, 105, 180)

{-| -}
hotPink : Color
hotPink =
    RGB (255, 0, 66)


{-| -}
lightRed : Color
lightRed =
    RGB (239, 41, 41)


{-| -}
red : Color
red =
    RGB (204, 0, 0)


{-| -}
darkRed : Color
darkRed =
    RGB (164, 0, 0)


{-| -}
lightOrange : Color
lightOrange =
    RGB (252, 175, 62)


{-| -}
orange : Color
orange =
    RGB (245, 121, 0)


{-| -}
darkOrange : Color
darkOrange =
    RGB (206, 92, 0)


{-| -}
lightYellow : Color
lightYellow =
    RGB (255, 233, 79)


{-| -}
yellow : Color
yellow =
    RGB (237, 212, 0)


{-| -}
darkYellow : Color
darkYellow =
    RGB (196, 160, 0)


{-| -}
lightGreen : Color
lightGreen =
    RGB (138, 226, 52)


{-| -}
green : Color
green =
    RGB (115, 210, 22)


{-| -}
darkGreen : Color
darkGreen =
    RGB (78, 154, 6)


{-| -}
lightBlue : Color
lightBlue =
    RGB (114, 159, 207)


{-| -}
blue : Color
blue =
    RGB (52, 101, 164)


{-| -}
darkBlue : Color
darkBlue =
    RGB (32, 74, 135)


{-| -}
lightPurple : Color
lightPurple =
    RGB (173, 127, 168)


{-| -}
purple : Color
purple =
    RGB (117, 80, 123)


{-| -}
darkPurple : Color
darkPurple =
    RGB (92, 53, 102)


{-| -}
lightBrown : Color
lightBrown =
    RGB (233, 185, 110)


{-| -}
brown : Color
brown =
    RGB (193, 125, 17)


{-| -}
darkBrown : Color
darkBrown =
    RGB (143, 89, 2)


{-| -}
black : Color
black =
    RGB (0, 0, 0)


{-| -}
white : Color
white =
    RGB (255, 255, 255)


{-| -}
lightGrey : Color
lightGrey =
    RGB (238, 238, 236)


{-| -}
grey : Color
grey =
    RGB (211, 215, 207)


{-| -}
darkGrey : Color
darkGrey =
    RGB (186, 189, 182)


{-| -}
lightGray : Color
lightGray =
    RGB (238, 238, 236)


{-| -}
gray : Color
gray =
    RGB (211, 215, 207)


{-| -}
darkGray : Color
darkGray =
    RGB (186, 189, 182)


{-| -}
lightCharcoal : Color
lightCharcoal =
    RGB (136, 138, 133)


{-| -}
charcoal : Color
charcoal =
    RGB (85, 87, 83)


{-| -}
darkCharcoal : Color
darkCharcoal =
    RGB (46, 52, 54)


{-| -}
blank : Color
blank =
    RGB (0, 0, 0)
