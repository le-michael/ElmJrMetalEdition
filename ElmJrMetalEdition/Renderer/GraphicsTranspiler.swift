//
//  GraphicsTranspiler.swift
//  ElmJrMetalEdition
//
//  Created by Saad Khan on 2021-01-29.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import Foundation
 
func transpile(node: EINode) -> EGGraphicsNode{
    var scene = EGScene()
    var shapes = [EGGraphicsNode]()
    switch node {
    case let literal as EILiteral:
        print(literal)
        
    case let unOp as EIAST.UnaryOp:
        print(unOp)
        
    case let binOp as EIAST.BinaryOp:
        print(binOp)
        
    case let inst as EIAST.ConstructorInstance:
        switch inst.constructorName {
        case "Scene":
            for param in inst.parameters{
                switch param{
                case let inst as EIAST.ConstructorInstance:
                    switch inst.constructorName{
                    case "Camera":
                        scene = cameraHelper(node: param, scene: scene)
                    default:
                        shapes.append(transpile(node: param))
                    }
                default: shapes.append(transpile(node: param))
                }
            }
            
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
                        transform = translateHelper(translate: param)
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
    case let tuple as EIAST.Tuple:
        print(tuple)
        
    case let list as EIAST.List:
        for node in list.items {
            return transpile(node: node)
        }
            
    default:
        break
    }
    
    for shape in shapes{
        scene.add(shape)
    }
    return scene
}

//make util function here for unwrapping
func unwrapFloat(wrappedFloat: EINode) -> Float{
    if let value = wrappedFloat as? EIAST.Integer {
        return Float(value.value)
    }
    else {
        return 3.0
    }
}

func unwrapInt(wrappedInt: EINode) -> Int{
    if let value = wrappedInt as? EIAST.Integer {
        return Int(value.value)
    }
    return 3
}

func transformHelper(shape: EGGraphicsNode, transform: [Float], transformType: String) -> EGGraphicsNode {
    //add swich for diff transforms
    if let poly = shape as? EGRegularPolygon {
        poly.transform.translate.set(x: transform[0], y: transform[1], z: transform[2])
        return poly
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

func translateHelper(translate: EINode) -> [Float] {
    if let translate = translate as? EIAST.ConstructorInstance {
        if let floats = translate.parameters[0] as? EIAST.Tuple {
            let x = unwrapFloat(wrappedFloat: floats.v1)
            let y = unwrapFloat(wrappedFloat: floats.v2)
            let z = unwrapFloat(wrappedFloat: floats.v3!)
            return [x,y,z]
        }
    }
    return [0,0,0,0]
}

func rgbHelper(rgbNode: EINode) -> [Float]{
    return  [204,0,0,1]
}

func polyHelper(polygon: Array<EINode>) -> EGRegularPolygon {
    
    return EGRegularPolygon(unwrapInt(wrappedInt: polygon[1]))
}

func inkedHelper(node: EINode) -> EGGraphicsNode{
    var RGBA = [Float]()
    var shape = EGPrimitive()
    if let inked = node as? EIAST.ConstructorInstance {
    for param in inked.parameters {
        switch param {
        case let param as EIAST.ConstructorInstance:
            switch param.constructorName{
            case "Just":
                RGBA = rgbHelper(rgbNode: param.parameters[0])
            case "Polygon":
                shape = polyHelper(polygon: param.parameters)
            default:
                break
            }
        default:
            break
        }
    }
    }
    //color is optional so change this logic
    shape.color.set(r: RGBA[0], g: RGBA[1], b: RGBA[2], a: RGBA[3])
    return shape
}

func cameraHelper(node: EINode, scene: EGScene) -> EGScene{
    var transform = [Float]()
    var transformType = String()
    var camera = EGCamera()
    switch node {
    case let camera as EIAST.ConstructorInstance:
        for param in camera.parameters{
            switch param{
            case let param as EIAST.ConstructorInstance:
                switch param.constructorName{
                case "Translate":
                    transformType = "Translate"
                    transform = translateHelper(translate: param)
                default:
                    print("def")
                }
            default:
                break
            }
        }
    default:
        break
    }
    camera = sceneTransformHelper(camera: camera, transform: transform, transformType: transformType)
    scene.camera = camera
    return scene
}

