//
//  GraphicsTranspiler.swift
//  ElmJrMetalEdition
//
//  Created by Saad Khan on 2021-01-29.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import Foundation

func transpile(node: EINode) -> EGGraphicsNode{
    let scene = EGScene()
    var shapes = [EGGraphicsNode]()
    var lightingDone = false
        
    switch node {
//    case let _ as EILiteral:
//        break
//
//    case let _ as EIAST.UnaryOp:
//        break
//
//    case let _ as EIAST.BinaryOp:
//        break
    
    
    case let inst as EIAST.ConstructorInstance:
        switch inst.constructorName {
        
        //add case for all camera types within this
        case "Scene":
            for param in inst.parameters{
                switch param{
                case let inst as EIAST.ConstructorInstance:
                    switch inst.constructorName{
                    case "Camera":
                        cameraHelper(node: param, scene: scene)
                    default:
                        shapes.append(transpile(node: param))
                    }
                case let list as EIAST.List:
                    //need a way to figure out if list of lighting
                    if(!lightingDone){
                        lightingDone = true
                        lightingHelper(list: list, scene: scene)
                    }
                    else{
                        shapes = shapesHelper(node: list)
                    }
                default:
                    break
                }
            }
        
        //add case for all camera types within this
        case "SceneWithTime":
            for param in inst.parameters{
                switch param{
                case let inst as EIAST.ConstructorInstance:
                    switch inst.constructorName{
                    case "ArcballCamera":
                        cameraHelper(node: param, scene: scene)
                    default:
                        shapes.append(transpile(node: param))
                    }
                case let list as EIAST.List:
                    //need a way to figure out if list of lighting
                    if(!lightingDone){
                        lightingDone = true
                        lightingHelper(list: list, scene: scene)
                    }
                case let function as EIAST.Function:
                    shapes = functionHelper(node: function)
                default:
                    break
                }
            }
            
        case "DirectionalLight":
            directionalLightHelper(node: inst, scene: scene)
        
        case "AmbientLight":
            ambientLightHelper(node: inst, scene: scene)
            
        case "Inked":
            return inkedHelper(node: inst)
            
        case "ApTransform":
            var shape = EGGraphicsNode()
            var transform = [Float]()
            var transformType = String()
            for param in inst.parameters{
                switch param{
                case let inst as EIAST.ConstructorInstance:
                    switch inst.constructorName{
                    case "Translate":
                        transformType = "Translate"
                        transform = unwrapTransform(transform: param)
                    case "Scale":
                        transformType = "Scale"
                        transform = unwrapTransform(transform: param)
                    case "Rotate3D":
                        transformType = "Rotate3D"
                        transform = unwrapTransform(transform: param)
                    case "Inked":
                        shape = inkedHelper(node: param)
                    case "ApTransform":
                        shape = transpile(node: param)
                    default:
                        break
                    }
                default:
                    break
                }
            }
            return transformHelper(shape: shape, transform: transform, transformType: transformType)
            
        default:
            break
        }
//    case let tuple as EIAST.Tuple:
//
//    case let list as EIAST.List:
//
            
    default:
        break
    }
    
    for shape in shapes{
        scene.add(shape)
    }
    return scene
}

func unwrapFloatingPoint(wrappedFloat: EINode) -> Float{
    if let value = wrappedFloat as? EIAST.FloatingPoint {
        return value.value
    }
    
    //weird case where integers are passed in but API wants floats so we gotta convert from into to float
    else {
        if let value = wrappedFloat as? EIAST.Integer{
            return Float(unwrapInt(wrappedInt: value))
        }
    }
    return 1.0
}

func unwrapInt(wrappedInt: EINode) -> Int{
    if let value = wrappedInt as? EIAST.Integer {
        return Int(value.value)
    }
    return 3
}

func unwrapTuple(tuple: EINode) -> [Float] {
    if let tuple = tuple as? EIAST.Tuple {
        let x = unwrapFloatingPoint(wrappedFloat: tuple.v1)
        let y = unwrapFloatingPoint(wrappedFloat: tuple.v2)
        let z = unwrapFloatingPoint(wrappedFloat: tuple.v3!)
        return [x,y,z]
    }
    return [0,0,0,0]
}


func transformHelper(shape: EGGraphicsNode, transform: [Float], transformType: String) -> EGGraphicsNode {
    //add swich for diff transforms
    //fix this to apply transforms to the generic shape withtout casting it to a specific shape
    if let poly = shape as? EGRegularPolygon {
        poly.transform.translate.set(x: transform[0], y: transform[1], z: transform[2])
        return poly
    }
    if let sphere = shape as? EGSphere {
        switch transformType{
        case "Translate":
            sphere.transform.translate.set(x: transform[0], y: transform[1], z: transform[2])
        case "Scale":
            sphere.transform.scale.set(x: transform[0], y: transform[1], z: transform[2])
        default:
            break
        }
    }
    if let capsule = shape as? EGCapsule {
        switch transformType{
        case "Rotate3D":
            capsule.transform.rotate.set(x: transform[0].degreesToRadians, y: transform[1], z: transform[2])
        case "Scale":
            capsule.transform.scale.set(x: transform[0], y: transform[1], z: transform[2])
        case "Translate":
            capsule.transform.translate.set(x: transform[0], y: transform[1], z: transform[2])
        default:
            break
        }
    }
    
    if let cylinder = shape as? EGCylinder {
        switch transformType{
        case "Translate":
            cylinder.transform.translate.set(x: transform[0], y: transform[1], z: transform[2])
        case "Scale":
            cylinder.transform.scale.set(x: transform[0], y: transform[1], z: transform[2])
        case "Rotate3D":
            cylinder.transform.rotate.set(x: transform[0].degreesToRadians, y: transform[1], z: transform[2])
        default:
            break
        }
    }
    return shape
}

func sceneTransformHelper(camera: EGCamera, transform: [Float], transformType: String) -> EGCamera{
    switch transformType{
    case "translate":
        camera.transform.translate.set(x: transform[0], y: transform[1], z: transform[2])
        return camera
    default:
        return camera
    }
}

func unwrapTransform(transform: EINode) -> [Float] {
    if let transform = transform as? EIAST.ConstructorInstance {
        if let floats = transform.parameters[0] as? EIAST.Tuple {
            let x = unwrapFloatingPoint(wrappedFloat: floats.v1)
            let y = unwrapFloatingPoint(wrappedFloat: floats.v2)
            let z = unwrapFloatingPoint(wrappedFloat: floats.v3!)
            return [x,y,z]
        }
    }
    return [0,0,0,0]
}

//rgba helper fix this
func rgbaHelper(node: EINode) -> [Float]{
    var values = [Float]()
    switch node{
    case let rgba as EIAST.ConstructorInstance:
        for value in rgba.parameters{
            values.append(unwrapFloatingPoint(wrappedFloat: value))
        }
    default: break
    }
    return  values
}

//rgbhelper
func rgbHelper(node: EINode) -> simd_float3 {
    var values = [Float]()
    var rgb = simd_float3()
    switch node{
    case let rgb as EIAST.ConstructorInstance:
        for value in rgb.parameters{
            values.append(unwrapFloatingPoint(wrappedFloat: value))
        }
    default: break
    }
    rgb.x = values[0]
    rgb.y = values[1]
    rgb.z = values[2]
    return rgb
}

func polyHelper(polygon: Array<EINode>) -> EGRegularPolygon {
    
    return EGRegularPolygon(unwrapInt(wrappedInt: polygon[1]))
}

func simd3Helper(tuple: [Float])-> simd_float3 {
    return simd_float3(tuple[0], tuple[1], tuple[2])
}

func inkedHelper(node: EINode) -> EGGraphicsNode{
    //var RGBA = simd_float4()
    var RGBA = [Float]()
    var shape = EGPrimitive()
    if let inked = node as? EIAST.ConstructorInstance {
    for param in inked.parameters {
        switch param {
        case let param as EIAST.ConstructorInstance:
            switch param.constructorName{
            case "Just":
                //this is hacky just skips optional validation
                RGBA = rgbaHelper(node: param.parameters[0])
            case "Polygon":
                shape = polyHelper(polygon: param.parameters)
            case "Sphere":
                shape = EGSphere()
            case "Capsule":
                shape = EGCapsule()
            case "Cylinder":
                shape = EGCylinder()
            break
            default:
                break
            }
        default:
            break
        }
    }
    }
    //color is optional so change this logic
    if let sphere = shape as? EGSphere{
        sphere.submeshColorMap[0] = EGColorProperty(r: RGBA[0], g: RGBA[1], b: RGBA[2], a: RGBA[3])
    }
    if let capsule = shape as? EGCapsule{
        capsule.submeshColorMap[0] = EGColorProperty(r: RGBA[0], g: RGBA[1], b: RGBA[2], a: RGBA[3])
    }
    if let cylinder = shape as? EGCylinder{
        cylinder.submeshColorMap[0] = EGColorProperty(r: RGBA[0], g: RGBA[1], b: RGBA[2], a: RGBA[3])
    }
    //shape.color.set(r: RGBA[0], g: RGBA[1], b: RGBA[2], a: RGBA[3])
    return shape
}

func cameraHelper(node: EINode, scene: EGScene){
    var transform = [Float]()
    var transformType = String()
    var camera = EGCamera()
    var distance = Float()
    var target = simd_float3()
    var arcball = false
    switch node {
    case let camera as EIAST.ConstructorInstance:
        
        
        switch camera.constructorName{
        case "Camera":
            for param in camera.parameters{
                switch param{
                case let param as EIAST.ConstructorInstance:
                    switch param.constructorName{
                    case "Translate":
                        transformType = "Translate"
                        transform = unwrapTransform(transform: param)
                    default:
                        break
                    }
                default:
                    break
                }
            }
        //move this case into own method and clean up logic this is disgusting
        case "ArcballCamera":
            arcball = true
            for param in camera.parameters{
                switch param{
                case let inst as EIAST.ConstructorInstance:
                    switch inst.constructorName{
                    case "Nothing":
                        break
                    default:
                        break
                    }
                case let tuple as EIAST.Tuple:
                    target =  simd3Helper(tuple: unwrapTuple(tuple: tuple))
                case let int as EIAST.Integer:
                    //arcball constructor wants a float therefore have to unwrap as int then cast to float
                    distance = Float(unwrapInt(wrappedInt: int))
                default:
                    break
                }
            }
        default:
            break
        }

        
    default:
        break
    }
    
    //kinda hardcoded for snowman example need to add to logic to deal with the last two parameters in arcball
    if arcball {
        camera = EGArcballCamera(distance: distance, target: target)
        scene.camera = camera
    }
    else{
        camera = sceneTransformHelper(camera: camera, transform: transform, transformType: transformType)
        scene.camera = camera
    }

}

func directionalLightHelper(node: EINode, scene: EGScene){
    var color = simd_float3()
    var position = simd_float3()
    var specularColor = simd_float3()
    var seenColour = false
    
    
    switch node{
    case let inst as EIAST.ConstructorInstance:
        for param in inst.parameters{
            switch param{
            case let inst as EIAST.ConstructorInstance:
                if(!seenColour){
                    seenColour = true
                    color = rgbHelper(node: inst)
                }
                else{
                    specularColor = rgbHelper(node: inst)
                }
            case let tuple as EIAST.Tuple:
                position = simd3Helper(tuple: unwrapTuple(tuple: tuple))
            default:
                break
            }
        }
    default:
        break
    }
    scene.lights.append(EGLight.directional(color: color, position: position, intensity: 0 , specularColor: specularColor))
}

func ambientLightHelper(node: EINode, scene: EGScene){
    var color = simd_float3()
    var intensity = Float()
    switch node{
    case let inst as EIAST.ConstructorInstance:
        for param in inst.parameters{
            switch param{
            case let inst as EIAST.ConstructorInstance:
                color = rgbHelper(node: inst)
            case let float as EIAST.FloatingPoint:
                intensity = unwrapFloatingPoint(wrappedFloat: float)
            default:
                break
            }
            
        }
    default:
        break
    }
    scene.lights.append(EGLight.ambient(color: color, intensity:intensity))
}

func lightingHelper(list: EIAST.List, scene: EGScene){
    switch list{
    case let list as EIAST.List:
        for item in list.items{
            switch item{
            case let inst as EIAST.ConstructorInstance:
                switch inst.constructorName{
                
                    case "DirectionalLight":
                    directionalLightHelper(node: inst, scene: scene)
            
                    case "AmbientLight":
                    ambientLightHelper(node: inst, scene: scene)
                        
                default:
                    break
            }
            default:
                break
        }
    }

    }
    }

func shapesHelper(node: EIAST.List) -> [EGGraphicsNode]{
    var shapes = [EGGraphicsNode]()
    for shape in node.items{
        shapes.append(transpile(node: shape))
    }
    return shapes
}

func functionHelper(node: EIAST.Function) -> [EGGraphicsNode]{
    let isnt = node.body as! EIAST.List
    let shapes = shapesHelper(node: isnt)
    return shapes
}

