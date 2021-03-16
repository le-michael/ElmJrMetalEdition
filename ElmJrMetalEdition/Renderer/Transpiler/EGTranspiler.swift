//
//  TranspilerRefactor.swift
//  ElmJrMetalEdition
//
//  Created by Saad Khan on 2021-02-09.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import Foundation
class EGTranspiler {
    func transpile(node: EINode) -> EGScene {
        var node = node
        if let function = node as? EIAST.Function {
            node = function.body
        }
        let scene = EGScene()
        sceneTranspiler(node: node, scene: scene)
        let shapes = shapesTranspiler(node: node)
        for shape in shapes {
            scene.add(shape)
        }
        return scene
    }

    func sceneTranspiler(node: EINode, scene: EGScene) {
        let inst = node as! EIAST.ConstructorInstance
        for param in inst.parameters {
            switch param {
            case let camera as EIAST.ConstructorInstance:
                let typeOfCamera = camera.constructorName
                if typeOfCamera == "ArcballCamera" {
                    arcballCameraTranspiler(scene: scene, node: camera)
                }
                else if typeOfCamera == "Camera" {
                    cameraTranspiler(scene: scene, node: camera)
                }
                else {
                    print("Not sure what this RGB Parameter is for so this is a placeholder")
                }
            case let list as EIAST.List:
                lightingTranspiler(scene: scene, lightingList: list)
            case let function as EIAST.Function:
                let list = function.body as! EIAST.List
                lightingTranspiler(scene: scene, lightingList: list)
            default:
                break
            }
        }
    }

    func cameraTranspiler(scene: EGScene, node: EINode) {
        let camera = EGCamera()
        let node = node as! EIAST.ConstructorInstance

        let transform = node.parameters[0] as! EIAST.ConstructorInstance
        switch transform.constructorName {
        case "Translate":
            let cameraTransform = unwrapTransform(transform: transform)
            camera.transform.translate.set(x: cameraTransform[0], y: cameraTransform[1], z: cameraTransform[2])
        case "Scale":
            let cameraTransform = unwrapTransform(transform: transform)
            camera.transform.scale.set(x: cameraTransform[0], y: cameraTransform[1], z: cameraTransform[2])
        case "Rotate3D":
            let cameraTransform = unwrapTransform(transform: transform)
            camera.transform.rotate.set(x: cameraTransform[0], y: cameraTransform[1], z: cameraTransform[2])
        default:
            break
        }
        scene.camera = camera
    }

    func arcballCameraTranspiler(scene: EGScene, node: EINode) {
        var distance = Float()
        var target = simd_float3()
        var rotation = simd_float3()
        var rotate = false

        let camera = node as! EIAST.ConstructorInstance
        for param in camera.parameters {
            switch param {
            case let int as EIAST.Integer:
                distance = unwrapFloat(wrappedFloat: int)
            case let tuple as EIAST.Tuple:
                target = unwrapTuple(wrappedTuple: tuple)
            case let inst as EIAST.ConstructorInstance:
                if inst.constructorName == "Just" {
                    rotation = unwrapTuple(wrappedTuple: inst.parameters[0])
                    rotate = true
                }
            default:
                break
            }
        }

        let arcballCamera = EGArcballCamera(distance: distance, target: target)
        if rotate {
            arcballCamera.rotation = rotation
        }
        scene.camera = arcballCamera
        print("Set Arcball Camera")
    }

    func lightingTranspiler(scene: EGScene, lightingList: EINode) {
        let list = lightingList as! EIAST.List
        for item in list.items {
            let inst = item as! EIAST.ConstructorInstance
            switch inst.constructorName {
            case "DirectionalLight":
                directionalLightTranspiler(scene: scene, node: inst)
            case "AmbientLight":
                ambientLightTranspiler(scene: scene, node: inst)
            case "Point":
                pointLightTranspiler(scene: scene, node: inst)
            case "Spotlight":
                spotlightTranspiler(scene: scene, node: inst)
            default:
                break
            }
        }
    }
    
    func pointLightTranspiler(scene: EGScene, node: EINode) {
        let inst = node as! EIAST.ConstructorInstance
        let rgb = inst.parameters[1] as! EIAST.ConstructorInstance
        let color = tupleTransform(node: rgb.parameters[0])
        let position = tupleTransform(node: inst.parameters[2])
        let attenuation = tupleTransform(node: inst.parameters[3])
        scene.lights.append(
            EGPointLight.init(color: color, position: position, attenuation: attenuation)
      )
    }
    
    func spotlightTranspiler(scene: EGScene, node: EINode) {
        let inst = node as! EIAST.ConstructorInstance
        let rgb = inst.parameters[1] as! EIAST.ConstructorInstance
        let color = tupleTransform(node: rgb.parameters[0])
        let position = tupleTransform(node: inst.parameters[2])
        let attenuation = tupleTransform(node: inst.parameters[3])
        let coneAngle = constructTransform(node: inst.parameters[4])
        let coneDirection = tupleTransform(node: inst.parameters[5])
        let coneAttenuation = constructTransform(node: inst.parameters[6])
        scene.lights.append(EGSpotLight(color: color, position: position, attenuation: attenuation, coneAngle: coneAngle, coneDirection: coneDirection, coneAttenuation: coneAttenuation))
    }
    
    func tupleTransform(node: EINode) -> EGMathNode3 {
        let tuple = node as! EIAST.Tuple
        var transform = [EGMathNode]()
        transform.append(constructTransform(node: tuple.v1))
        transform.append(constructTransform(node: tuple.v2))
        transform.append(constructTransform(node: tuple.v3!))
        return (transform[0], transform[1], transform[2])
    }
    
    func directionalLightTranspiler(scene: EGScene, node: EINode) {
        let inst = node as! EIAST.ConstructorInstance
        //use color helper for animations
        var rgb = inst.parameters[1] as! EIAST.ConstructorInstance
        let color = tupleTransform(node: rgb.parameters[0])
        let position = tupleTransform(node: inst.parameters[2])
        rgb = inst.parameters[3] as! EIAST.ConstructorInstance
        let specularColor = tupleTransform(node: rgb.parameters[0])
        scene.lights.append(
            EGDirectionaLight(
                color: color,
                position: position,
                intensity: EGConstant(0),
                specularColor: specularColor)
            )
        print("Set Directional Light with colour:", color, ", position:", position, "specularColor:", specularColor)
    }

    func ambientLightTranspiler(scene: EGScene, node: EINode) {
        let inst = node as! EIAST.ConstructorInstance
        let rgb = inst.parameters[1] as! EIAST.ConstructorInstance
        let color = tupleTransform(node: rgb.parameters[0])
        let intensity = EGConstant(unwrapFloat(wrappedFloat: inst.parameters[2]))
        scene.lights.append(
            EGAmbientLight(
                color: color,
                intensity: intensity
            )
        )
        print("Set Ambient Light with color:", color, ", intensity:", intensity)
    }

    func rgbHelper(node: EINode) -> simd_float3 {
        let rgb = node as! EIAST.ConstructorInstance
        return unwrapTuple(wrappedTuple: rgb.parameters[0])
    }

    func shapesTranspiler(node: EINode) -> [EGGraphicsNode] {
        var shapes = [EGGraphicsNode]()
        let inst = node as! EIAST.ConstructorInstance
        if let function = inst.parameters[3] as? EIAST.Function {
            let list = function.body as! EIAST.List
            for shape in list.items {
                shapes.append(addShape(node: shape))
            }
        }
        else {
            let list = inst.parameters[3] as! EIAST.List
            for shape in list.items {
                shapes.append(addShape(node: shape))
            }
        }
        return shapes
    }

    func addShape(node: EINode) -> EGGraphicsNode {
        switch node {
        case let inst as EIAST.ConstructorInstance:
            switch inst.constructorName {
            case "Inked":
                return inkedHelper(node: inst)
            case "ApTransform":
                return apTransformHelper(node: inst)
            case "Group":
                let group = EGGroup()
                let list = inst.parameters[0] as! EIAST.List
                for shape in list.items {
                    group.add(addShape(node: shape))
                }
                return group
            default:
                break
            }
        default:
            break
        }
        return EGGraphicsNode()
    }

    func apTransformHelper(node: EINode) -> EGGraphicsNode {
        var shape = EGGraphicsNode()
        var transform = [EGMathNode]()
        var transformType = String()
        let inst = node as! EIAST.ConstructorInstance
        for paramater in inst.parameters {
            let param = paramater as! EIAST.ConstructorInstance
            switch param.constructorName {
            case "Translate":
                transformType = "Translate"
                transform = unwrapTransform(transform: param)
            case "Scale":
                transformType = "Scale"
                transform = unwrapTransform(transform: param)
            case "Rotate3D":
                transformType = "Rotate3D"
                transform = unwrapTransform(transform: param)
            case "Rotate2D":
                break
            case "Inked":
                shape = inkedHelper(node: param)
            case "ApTransform":
                shape = apTransformHelper(node: param)
            case "Group":
                shape = addShape(node: param)
            default:
                break
            }
        }
        return applyTransform(shape: shape, transform: transform, transformType: transformType)
    }

    func unwrapTransform(transform: EINode) -> [EGMathNode] {
        let transform = transform as! EIAST.ConstructorInstance
        let tuple = transform.parameters[0] as! EIAST.Tuple

        let x = constructTransform(node: tuple.v1)
        let y = constructTransform(node: tuple.v2)
        let z = constructTransform(node: tuple.v3!)
        return [x, y, z]
    }

    func constructTransform(node: EINode) -> EGMathNode {
        switch node {
        case let variable as EIAST.Variable:
            switch variable.name {
            case "time":
                return EGTime()
            default:
                break
            }

        case let int as EIAST.Integer:
            return EGConstant(Float(unwrapFloat(wrappedFloat: int)))

        case let float as EIAST.FloatingPoint:
            return EGConstant(unwrapFloat(wrappedFloat: float))

        case let unOp as EIAST.UnaryOp:
            let unaryOp = EGUnaryOp(
                type: unOptypeConverter(type: unOp.type.rawValue),
                child: constructTransform(node: unOp.operand)
            )
            return unaryOp

        case let binOp as EIAST.BinaryOp:
            let binaryOp = EGBinaryOp(
                type: binOptypeConverter(type: binOp.type.rawValue),
                leftChild: constructTransform(node: binOp.leftOperand),
                rightChild: constructTransform(node: binOp.rightOperand)
            )
            return binaryOp

        case let inst as EIAST.ConstructorInstance:

            if inst.parameters.count == 1 {
                let unaryOp = EGUnaryOp(
                    type: unOptypeConverter(type: inst.constructorName),
                    child: constructTransform(node: inst.parameters[0])
                )
                return unaryOp
            }

            let binaryOp = EGBinaryOp(
                type: binOptypeConverter(type: inst.constructorName),
                leftChild: constructTransform(node: inst.parameters[0]),
                rightChild: constructTransform(node: inst.parameters[1])
            )
            return binaryOp

        default:
            break
        }
        return EGConstant(1)
    }

    func binOptypeConverter(type: String) -> EGBinaryOp.BinaryOpType {
        switch type {
        case "+":
            return .add
        case "-":
            return .sub
        case "*":
            return .mul
        case "/":
            return .div

        // not sure if cases below are correct
        case "Max":
            return .max
        case "Min":
            return .min
        default:
            return .add
        }
    }

    func unOptypeConverter(type: String) -> EGUnaryOp.UnaryOpType {
        switch type {
        case "Sin":
            return .sin
        case "Cos":
            return .cos
        case "Tan":
            return .tan

        // not sure if cases below are corret
        case "Neg":
            return .neg
        case "Abs":
            return .abs
        default:
            return .sin
        }
    }

    func applyTransform(shape: EGGraphicsNode, transform: [EGMathNode], transformType: String) -> EGGraphicsNode {
        
        //temporary logic until i can think of a more elegant solution
        if let shape = shape as? EGModel{
        
        switch transformType {
        case "Translate":
            let equations = shape.transform.translate.equations
            shape.transform.translate.set(x: EGBinaryOp(type: .add, leftChild: equations.x, rightChild: transform[0]),
                                          y: EGBinaryOp(type: .add, leftChild: equations.y, rightChild: transform[1]),
                                          z: EGBinaryOp(type: .add, leftChild: equations.z, rightChild: transform[2]))
            print("Applied Translate")
        case "Scale":
            let equations = shape.transform.scale.equations
            shape.transform.scale.set(x: EGBinaryOp(type: .mul, leftChild: equations.x, rightChild: transform[0]),
                                      y: EGBinaryOp(type: .mul, leftChild: equations.y, rightChild: transform[1]),
                                      z: EGBinaryOp(type: .mul, leftChild: equations.z, rightChild: transform[2]))
            print("Applied Scale")
        case "Rotate3D":
            let equations = shape.transform.rotate.equations
            shape.transform.rotate.set(x: EGBinaryOp(type: .add, leftChild: equations.x, rightChild: transform[0]),
                                       y: EGBinaryOp(type: .add, leftChild: equations.y, rightChild: transform[1]),
                                       z: EGBinaryOp(type: .add, leftChild: equations.z, rightChild: transform[2]))
            print("Applied Rotation")
        default:
            break
        }
        }
        else {
            let shape = shape as! EGGroup
            switch transformType {
            case "Translate":
                let equations = shape.transform.translate.equations
                shape.transform.translate.set(x: EGBinaryOp(type: .add, leftChild: equations.x, rightChild: transform[0]),
                                              y: EGBinaryOp(type: .add, leftChild: equations.y, rightChild: transform[1]),
                                              z: EGBinaryOp(type: .add, leftChild: equations.z, rightChild: transform[2]))
                print("Applied Translate")
            case "Scale":
                let equations = shape.transform.scale.equations
                shape.transform.scale.set(x: EGBinaryOp(type: .mul, leftChild: equations.x, rightChild: transform[0]),
                                          y: EGBinaryOp(type: .mul, leftChild: equations.y, rightChild: transform[1]),
                                          z: EGBinaryOp(type: .mul, leftChild: equations.z, rightChild: transform[2]))
                print("Applied Scale")
            case "Rotate3D":
                let equations = shape.transform.rotate.equations
                shape.transform.rotate.set(x: EGBinaryOp(type: .add, leftChild: equations.x, rightChild: transform[0]),
                                           y: EGBinaryOp(type: .add, leftChild: equations.y, rightChild: transform[1]),
                                           z: EGBinaryOp(type: .add, leftChild: equations.z, rightChild: transform[2]))
                print("Applied Rotation")
            default:
                break
            }
            }
        return shape
    }

    func inkedHelper(node: EINode) -> EGGraphicsNode {
        var color = [[EGMathNode]]()
        var isColored = false
        var shape = EGGraphicsNode()
        let inked = node as! EIAST.ConstructorInstance
        for param in inked.parameters {
            switch param {
            case let inst as EIAST.ConstructorInstance:
                switch inst.constructorName {
                case "Sphere":
                    shape = EGSphere()
                    print("Created Sphere")
                case "Cube":
                    shape = EGCube()
                    print("Created Cube")
                case "Polygon":
                    print("Created Polygon")
                    shape = EGRegularPolygon(Int(unwrapFloat(wrappedFloat: inst.parameters[0])))
                case "Cone":
                    shape = EGCone()
                    print("Created Cone")
                case "Cylinder":
                    shape = EGCylinder()
                    print("Created Cylinder")
                case "Capsule":
                    shape = EGCapsule()
                    print("Created Capsule")
                case "Model":
                    guard let param = inst.parameters[0] as? EIAST.Str else {
                        return EGSphere()
                    }
                    shape = EGModel(modelName: param.value)
                case "Smooth":
                    shape = inkedHelper(node: inst.parameters[1])
                    let shape = shape as! EGModel
                    shape.smoothIntensity = unwrapFloat(wrappedFloat: inst.parameters[0])
                case "Shininess":
                    break
                default:
                    break
                }
            case let list as EIAST.List:
                for item in list.items{
                    isColored = true
                    color.append(colorHelper(node: item))
                }
            default:
                break
            }
        }

        let model = shape as! EGModel
        if isColored {
            var index = 0
            for colors in color {
                model.submeshColorMap[index] = EGColorProperty()
                model.submeshColorMap[index]?.set(r: colors[0], g: colors[1], b: colors[2], a: EGConstant(1))
                index+=1
            }
            print("coloured shape")
        }
        return shape
    }
    
    func colorHelper(node: EINode) -> [EGMathNode] {
        var values = [EGMathNode]()
        let colors = node as! EIAST.ConstructorInstance
        let rgb = colors.parameters[0] as! EIAST.Tuple
        values.append(constructTransform(node: rgb.v1))
        values.append(constructTransform(node: rgb.v2))
        values.append(constructTransform(node: rgb.v3!))
        return values
    }

    func unwrapFloat(wrappedFloat: EINode) -> Float {
        if let value = wrappedFloat as? EIAST.FloatingPoint {
            return value.value
        }
        else {
            let value = wrappedFloat as! EIAST.Integer
            return Float(value.value)
        }
    }

    func unwrapTuple(wrappedTuple: EINode) -> simd_float3 {
        var unwrappedTuple = simd_float3()
        let tuple = wrappedTuple as! EIAST.Tuple
        unwrappedTuple.x = unwrapFloat(wrappedFloat: tuple.v1)
        unwrappedTuple.y = unwrapFloat(wrappedFloat: tuple.v2)
        unwrappedTuple.z = unwrapFloat(wrappedFloat: tuple.v3!)
        return unwrappedTuple
    }
}
