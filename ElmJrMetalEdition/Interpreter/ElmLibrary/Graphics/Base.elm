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
    = Inked (Maybe Color) (Maybe Float) (Maybe Float) Stencil -- Base constructor: apply colour to a Stencil
    -- | Texture String Stencil
    | Model String (Maybe (List Color))
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

color : Color -> Stencil -> Shape
color c stencil =
    Inked (Just c) stencil

model : String -> (Maybe (List Color)) -> Shape
model s mxs = Model mxs

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
rgb r g b = RGBA (ssa r) (ssc g) (ssc b) 1

rgba : Float -> Float -> Float -> Float -> Color
rgba r g b a = RGBA (ssc r) (ssc g) (ssc b) (ssa a)

pi : Float
pi = 3.141592653589793

-- deg to rad
rad : Float -> Float
rad n = n * pi/180

-- rad to deg
deg : Float -> Float
deg n = n * 180/pi

-- Default available colors

{-| -}
pink : Color
pink =
    RGBA 255 105 180 1


{-| -}
hotPink : Color
hotPink =
    RGBA 255 0 66 1


{-| -}
lightRed : Color
lightRed =
    RGBA 239 41 41 1


{-| -}
red : Color
red =
    RGBA 204 0 0 1


{-| -}
darkRed : Color
darkRed =
    RGBA 164 0 0 1


{-| -}
lightOrange : Color
lightOrange =
    RGBA 252 175 62 1


{-| -}
orange : Color
orange =
    RGBA 245 121 0 1


{-| -}
darkOrange : Color
darkOrange =
    RGBA 206 92 0 1


{-| -}
lightYellow : Color
lightYellow =
    RGBA 255 233 79 1


{-| -}
yellow : Color
yellow =
    RGBA 237 212 0 1


{-| -}
darkYellow : Color
darkYellow =
    RGBA 196 160 0 1


{-| -}
lightGreen : Color
lightGreen =
    RGBA 138 226 52 1


{-| -}
green : Color
green =
    RGBA 115 210 22 1


{-| -}
darkGreen : Color
darkGreen =
    RGBA 78 154 6 1


{-| -}
lightBlue : Color
lightBlue =
    RGBA 114 159 207 1


{-| -}
blue : Color
blue =
    RGBA 52 101 164 1


{-| -}
darkBlue : Color
darkBlue =
    RGBA 32 74 135 1


{-| -}
lightPurple : Color
lightPurple =
    RGBA 173 127 168 1


{-| -}
purple : Color
purple =
    RGBA 117 80 123 1


{-| -}
darkPurple : Color
darkPurple =
    RGBA 92 53 102 1


{-| -}
lightBrown : Color
lightBrown =
    RGBA 233 185 110 1


{-| -}
brown : Color
brown =
    RGBA 193 125 17 1


{-| -}
darkBrown : Color
darkBrown =
    RGBA 143 89 2 1


{-| -}
black : Color
black =
    RGBA 0 0 0 1


{-| -}
white : Color
white =
    RGBA 255 255 255 1


{-| -}
lightGrey : Color
lightGrey =
    RGBA 238 238 236 1


{-| -}
grey : Color
grey =
    RGBA 211 215 207 1


{-| -}
darkGrey : Color
darkGrey =
    RGBA 186 189 182 1


{-| -}
lightGray : Color
lightGray =
    RGBA 238 238 236 1


{-| -}
gray : Color
gray =
    RGBA 211 215 207 1


{-| -}
darkGray : Color
darkGray =
    RGBA 186 189 182 1


{-| -}
lightCharcoal : Color
lightCharcoal =
    RGBA 136 138 133 1


{-| -}
charcoal : Color
charcoal =
    RGBA 85 87 83 1


{-| -}
darkCharcoal : Color
darkCharcoal =
    RGBA 46 52 54 1


{-| -}
blank : Color
blank =
    RGBA 0 0 0
