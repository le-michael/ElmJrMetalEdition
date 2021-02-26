//
//  TranspilerRefactor.swift
//  ElmJrMetalEdition
//
//  Created by Saad Khan on 2021-02-09.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import Foundation

func transpile(node: EINode) -> EGScene {
    var node = node
    if let function = node as? EIAST.Function{
        node = function.body
    }
    let scene = EGScene()
    print(node)
    sceneTranspiler(node: node, scene: scene)
    let shapes = shapesTranspiler(node: node)
    print(shapes)
    for shape in shapes{
        scene.add(shape)
    }
    return scene
}

func sceneTranspiler(node: EINode, scene: EGScene){

    let inst = node as! EIAST.ConstructorInstance
    for param in inst.parameters{
        switch param{
        case let camera as EIAST.ConstructorInstance:
            let typeOfCamera = camera.constructorName
            if typeOfCamera == "ArcballCamera"{
                arcballCameraHelper(scene: scene, node: camera)
            }
            else if typeOfCamera == "Camera"{
                cameraHelper(scene: scene, node: camera)
            }
            else{
                print("Dealing with that color")
            }
        case let list as EIAST.List:
            print(list)
            lightingHelper(scene: scene, lightingList: list)
        default:
        break
        }
    }
}

func cameraHelper(scene: EGScene, node: EINode) {
    let camera = EGCamera()
    var cameraTransform = [EGMathNode]()
    var transformType = String()
    let node = node as! EIAST.ConstructorInstance

    let transform = node.parameters[0] as! EIAST.ConstructorInstance
    switch transform.constructorName{
    case "Translate":
        transformType = "Translate"
        cameraTransform = unwrapTransform(transform: transform, isRotation: false)
    case "Scale":
        transformType = "Scale"
        cameraTransform = unwrapTransform(transform: transform, isRotation: false)
    case "Rotate3D":
        transformType = "Rotate3D"
        cameraTransform = unwrapTransform(transform: transform, isRotation: true)
    default:
        break
    }

    switch transformType{
    case "Translate":
        camera.transform.translate.set(x: cameraTransform[0], y: cameraTransform[1], z: cameraTransform[2])
    case "Scale":
        camera.transform.scale.set(x: cameraTransform[0], y: cameraTransform[1], z: cameraTransform[2])
    case "Rotate3D":
        camera.transform.rotate.set(x: cameraTransform[0], y: cameraTransform[1], z: cameraTransform[2])
    default: break
    }
    scene.camera = camera
}

func arcballCameraHelper(scene: EGScene, node: EINode) {
    var distance = Float()
    var target = simd_float3()
    let camera = node as! EIAST.ConstructorInstance
    for param in camera.parameters{
        switch param{
        case let int as EIAST.Integer:
            distance = Float(unwrapInt(wrappedInt: int))
            //have to do this because arcball expects a float, but elm defines the paramater as an int
        case let tuple as EIAST.Tuple:
            target = unwrapTuple(wrappedTuple: tuple)
        default:
            break
        }
    }
    //TODO: clarify what the two optionals are for


    let arcballCamera = EGArcballCamera(distance: distance, target: target)
    //TODO: Figure out why rotation is missing from example
    scene.camera = arcballCamera
    print("Set Arcball Camera")
}

func lightingHelper(scene: EGScene, lightingList: EINode){
    let list = lightingList as! EIAST.List
    for item in list.items{
        let inst = item as! EIAST.ConstructorInstance
        switch inst.constructorName{
        case "DirectionalLight":
            directionalLightHelper(scene: scene, node: inst)
        case "AmbientLight":
            ambientLightHelper(scene: scene, node: inst)
        default:
            break
        }
    }
}

func directionalLightHelper(scene: EGScene, node: EINode){
    let inst = node as! EIAST.ConstructorInstance
    let color = rgbHelper(node: inst.parameters[0])
    let position = unwrapTuple(wrappedTuple: inst.parameters[1])
    let specularColor = rgbHelper(node: inst.parameters[2])
    scene.lights.append(EGLight.directional(color: color, position: position, intensity: 0, specularColor: specularColor))
    print("Set Directional Light with colour:",color,", position:", position, "specularColor:", specularColor)
}

func ambientLightHelper(scene: EGScene, node: EINode){
    let inst = node as! EIAST.ConstructorInstance
    //TODO: WHY IS RGB PASSING IN INTS
    let color = rgbHelper(node: inst.parameters[0])
    let intensity = unwrapFloat(wrappedFloat: inst.parameters[1])
    scene.lights.append(EGLight.ambient(color: color, intensity:intensity))
    print("Set Ambient Light with color:", color,", intensity:", intensity)
}

func rgbHelper(node: EINode) -> simd_float3 {
    var values = [Float]()
    var unwrappedRGB = simd_float3()

    let rgb = node as! EIAST.ConstructorInstance
    for value in rgb.parameters{
        values.append(unwrapFloat(wrappedFloat: value))
    }

    unwrappedRGB.x = values[0]
    unwrappedRGB.y = values[1]
    unwrappedRGB.z = values[2]

    return unwrappedRGB
}
func shapeHelper(){
    return
}

func shapesTranspiler(node: EINode) -> [EGGraphicsNode] {
    var shapes = [EGGraphicsNode]()
    let inst = node as! EIAST.ConstructorInstance
    if let function = inst.parameters[3] as? EIAST.Function{
        let list = function.body as! EIAST.List
        for shape in list.items{
            shapes.append(addShape(node: shape))
        }
    }
    else{
        let list = inst.parameters[3] as! EIAST.List
        for shape in list.items{
            shapes.append(addShape(node: shape))
        }
    }
    return shapes
}

func addShape(node: EINode) -> EGGraphicsNode {
    print("Dealing with shape: ", node)
    switch node{
    case let inst as EIAST.ConstructorInstance:
        switch inst.constructorName{
        case "Inked":
            return inkedHelper(node: inst)
        case "ApTransform":
            return apTransformHelper(node: inst)
        case "Group":
            break
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
    for paramater in inst.parameters{
        let param = paramater as! EIAST.ConstructorInstance
        switch param.constructorName {
        case "Translate":
            transformType = "Translate"
            transform = unwrapTransform(transform: param, isRotation: false)
        case "Scale":
            transformType = "Scale"
            transform = unwrapTransform(transform: param, isRotation: false)
        case "Rotate3D":
            transformType = "Rotate3D"
            transform = unwrapTransform(transform: param, isRotation: true)
        case "Inked":
            shape = inkedHelper(node:param)
        case "ApTransform":
            shape = apTransformHelper(node: param)
        default:
            break
        }
    }
    return applyTransform(shape: shape, transform: transform, transformType: transformType)
}

func unwrapTransform(transform: EINode, isRotation: Bool) -> [EGMathNode] {
    if let transform = transform as? EIAST.ConstructorInstance {
        if let floats = transform.parameters[0] as? EIAST.Tuple {
            //replace this with another function to scan for time and retunr a math node instead of this down here

            //need way to change degrees to radians
            if isRotation{
                let x = constructBinOP(node: floats.v1)
                let y = constructBinOP(node: floats.v2)
                let z = constructBinOP(node: floats.v3!)
                print("Passing back transform of ", floats.v1, floats.v2, floats.v3!)
                return [x,y,z]
            }

            let x = constructBinOP(node: floats.v1)
            let y = constructBinOP(node: floats.v2)
            let z = constructBinOP(node: floats.v3!)
            print("Passing back transform of ", floats.v1, floats.v2, floats.v3!)
            return [x,y,z]
        }
    }
    return [EGMathNode]()
}

func constructBinOP(node: EINode) -> EGMathNode{

    //what else can be a variable
    if let node = node as? EIAST.Variable{
        switch node.name{
        case "time":
            return EGTime()
        default:
            break
        }
    }

    if let node = node as? EIAST.Integer {
        //EGCoonstant only takes in float
        return EGConstant(Float(unwrapInt(wrappedInt: node)))
    }

    if let node = node as? EIAST.FloatingPoint {
        return EGConstant(unwrapFloat(wrappedFloat: node))
    }

    if let node = node as? EIAST.ConstructorInstance{
        if let unOp = node.parameters[0] as? EIAST.BinaryOp{
            let un = EGUnaryOp(
                type: unOptypeConverter(type: node.constructorName),
                child: constructBinOP(node: unOp)
            )
            return un
            //what if the node is a unaryOp?
            }
        }

    if let node = node as? EIAST.UnaryOp{
        let unOp = EGUnaryOp(
            type: unOptypeConverter(type: node.type.rawValue),
            child: constructBinOP(node: node.operand))
        return unOp
    }

    if let node = node as? EIAST.BinaryOp{
        print("left child:",type(of: node.leftOperand))
        print("right child:",type(of: node.rightOperand))
        let binOp = EGBinaryOp(
            type: binOptypeConverter(type: node.type.rawValue),
            leftChild: constructBinOP(node: node.leftOperand),
            rightChild: constructBinOP(node: node.rightOperand)
        )
        return binOp
    }
    return EGConstant(0)
}

func binOptypeConverter(type: String) -> EGBinaryOp.BinaryOpType {
    print(type)
    //TODO what about max and min
    switch type{
    case "+":
        return .add
    case "-":
        return .sub
    case "*":
        return .mul
    case "/":
        return .div
    default:
        return .add
    }
}

func unOptypeConverter(type: String) -> EGUnaryOp.UnaryOpType {
    switch type {
    case "Sin":
        return.sin
    default:
        return .sin
    }
}

func applyTransform(shape: EGGraphicsNode, transform: [EGMathNode], transformType: String) -> EGGraphicsNode {
    let shape = shape as! EGModel

    switch transformType{
    case "Translate":
        shape.transform.translate.set(x: transform[0], y: transform[1], z: transform[2])
        print("Applied Translate")
    case "Scale":
        shape.transform.scale.set(x: transform[0], y: transform[1], z: transform[2])
        print("Applied Scale")
    case "Rotate3D":
        shape.transform.rotate.set(x: transform[0], y: transform[1], z: transform[2])
        print("Applied Rotation")
    default:
        break
    }
    return shape
}

func inkedHelper(node: EINode) -> EGGraphicsNode{
    var color = [EGMathNode]()
    //var isColoured = false
    var shape = EGGraphicsNode()
    let inked = node as! EIAST.ConstructorInstance
    for param in inked.parameters{
        let inst = param as! EIAST.ConstructorInstance
        switch inst.constructorName{
        case "Just":
            color = colorHelper(node: inst.parameters[0])
            //isColoured = true
        case "Sphere":
            shape = EGSphere()
            print("Created Sphere")
        case "Cube":
            shape = EGCube()
            print("Created Cube")
        case "Polygon":
            print("Created Polygon")
            shape = EGRegularPolygon(unwrapInt(wrappedInt: inst.parameters[0]))
        case "Cone":
            shape = EGCone()
            print("Created Cone")
        case "Cylinder":
            shape = EGCylinder()
            print("Created Cylinder")
        case "Capsule":
            shape = EGCapsule()
            print("Created Capsule")
        default:
            break
        }
    }

    //TODO: need to deal with rgb also instead of just rgba
    if let new = shape as? EGModel{
        new.submeshColorMap[0] = EGColorProperty()
        new.submeshColorMap[0]?.set(r: color[0], g: color[1], b: color[2], a: color[3])
        print("coloured shape")
    }
    return shape
}

func colorHelper(node: EINode) -> [EGMathNode]{
    var values = [EGConstant]()
    let colors = node as! EIAST.ConstructorInstance
    for value in colors.parameters{
        values.append(EGConstant(unwrapFloat(wrappedFloat: value)))
    }
    return values
}

func wrapInConstant(node: EINode) -> EGConstant {
    return EGConstant(4)
}

func unwrapInt(wrappedInt: EINode) -> Int{
    let value = wrappedInt as! EIAST.Integer
    return Int(value.value)
}

func unwrapFloat(wrappedFloat: EINode) -> Float{
    if let value = wrappedFloat as? EIAST.FloatingPoint{
        return value.value
    }
    else {
        let value = wrappedFloat as! EIAST.Integer
        return Float(value.value)
    }
}

func unwrapTuple(wrappedTuple: EINode) -> simd_float3{
    var unwrappedTuple = simd_float3()
    let tuple = wrappedTuple as! EIAST.Tuple
    unwrappedTuple.x = Float(unwrapInt(wrappedInt: tuple.v1))
    unwrappedTuple.y = Float(unwrapInt(wrappedInt: tuple.v2))
    unwrappedTuple.z = Float(unwrapInt(wrappedInt: tuple.v3!))
    //More weird behaviour because ints are passed in but floats are needed for Metal API
    return unwrappedTuple
}

