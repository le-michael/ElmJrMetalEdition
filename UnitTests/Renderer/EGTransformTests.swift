//
//  EGTransformTests.swift
//  UnitTests
//
//  Created by Michael Le on 2020-11-23.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

@testable import ElmJrMetalEdition
import simd
import XCTest

class EGTransformTests: XCTestCase {
    var sceneProps: EGSceneProps!
    
    override func setUpWithError() throws {
        super.setUp()
        sceneProps = EGSceneProps(
            projectionMatrix: matrix_identity_float4x4,
            viewMatrix: matrix_identity_float4x4,
            time: 0
        )
    }
    
    func testEGTranslationMatrix() throws {
        let translate = EGTranslationMatrix()
        translate.setTranslation(x: 1, y: 10.2, z: 32.1)
        var expectedMatrix = matrix_float4x4(translation: [1, 10.2, 32.1])
        XCTAssert(translate.evaluate(sceneProps) == expectedMatrix)
        XCTAssert(translate.usesTime() == false)
        
        sceneProps.time = 1.22223
        translate.setTranslation(
            x: EGConstant(1.22),
            y: EGTime(),
            z: EGUnaryOp(type: .cos, child: EGTime())
        )
        expectedMatrix = matrix_float4x4(translation: [1.22, sceneProps.time, cos(sceneProps.time)])
        XCTAssert(translate.evaluate(sceneProps) == expectedMatrix)
        XCTAssert(translate.usesTime() == true)
        
        sceneProps.time = 2123.222
        translate.setTranslation(
            x: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .tan, child: EGTime())),
            y: EGUnaryOp(type: .sin, child: EGUnaryOp(type: .sin, child: EGConstant(1.22))),
            z: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .cos, child: EGTime()))
        )
        expectedMatrix = matrix_float4x4(translation: [
            cos(tan(sceneProps.time)),
            sin(sin(1.22)),
            cos(cos(sceneProps.time))
        ])
        XCTAssert(translate.evaluate(sceneProps) == expectedMatrix)
        XCTAssert(translate.usesTime() == true)
    }
    
    func testEGRotationMatrix() throws {
        let rotate = EGRotationMatrix()
        rotate.setRotation(x: 1, y: 2, z: 300)
        var expectedMatrix = matrix_float4x4(rotationX: 1)
            * matrix_float4x4(rotationY: 2)
            * matrix_float4x4(rotationZ: 300)
        XCTAssert(rotate.evaluate(sceneProps) == expectedMatrix)
        XCTAssert(rotate.usesTime() == false)
        
        sceneProps.time = 21.3
        rotate.setRotation(
            x: EGConstant(2),
            y: EGUnaryOp(type: .sin, child: EGUnaryOp(type: .cos, child: EGTime())),
            z: EGBinaryOp(type: .add, leftChild: EGUnaryOp(type: .tan, child: EGTime()), rightChild: EGTime())
        )
        expectedMatrix = matrix_float4x4(rotationX: 2)
            * matrix_float4x4(rotationY: sin(cos(sceneProps.time)))
            * matrix_float4x4(rotationZ: tan(sceneProps.time) + sceneProps.time)
        XCTAssert(rotate.evaluate(sceneProps) == expectedMatrix)
        XCTAssert(rotate.usesTime() == true)
        
        sceneProps.time = 2000.333
        rotate.setRotation(
            x: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .sin, child: EGBinaryOp(type: .add, leftChild: EGTime(), rightChild: EGConstant(1)))),
            y: EGBinaryOp(type: .sub, leftChild: EGTime(), rightChild: EGUnaryOp(type: .sin, child: EGUnaryOp(type: .cos, child: EGConstant(12)))),
            z: EGConstant(232)
        )
        expectedMatrix = matrix_float4x4(rotationX: cos(sin(sceneProps.time + 1)))
            * matrix_float4x4(rotationY: sceneProps.time - sin(cos(12)))
            * matrix_float4x4(rotationZ: 232)
        XCTAssert(rotate.evaluate(sceneProps) == expectedMatrix)
        XCTAssert(rotate.usesTime() == true)
    }
    
    func testEGScaleMatrix() throws {
        let scale = EGScaleMatrix()
        scale.setScale(x: 1, y: 2, z: 3)
        var expectedMatrix = matrix_float4x4(scale: [1, 2, 3])
        XCTAssert(scale.evaluate(sceneProps) == expectedMatrix)
        XCTAssert(scale.usesTime() == false)
        
        sceneProps.time = 123.2222
        scale.setScale(
            x: EGConstant(10.22),
            y: EGUnaryOp(type: .cos, child: EGTime()),
            z: EGUnaryOp(type: .sin, child: EGTime())
        )
        expectedMatrix = matrix_float4x4(scale: [
            10.22,
            cos(sceneProps.time),
            sin(sceneProps.time)
        ])
        XCTAssert(scale.evaluate(sceneProps) == expectedMatrix)
        XCTAssert(scale.usesTime() == true)
    
        sceneProps.time = 111.2222
        scale.setScale(
            x: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .sin, child: EGTime())),
            y: EGUnaryOp(type: .tan, child: EGTime()),
            z: EGUnaryOp(type: .sin, child: EGUnaryOp(type: .tan, child: EGConstant(2.33)))
        )
        expectedMatrix = matrix_float4x4(scale: [
            cos(sin(sceneProps.time)),
            tan(sceneProps.time),
            sin(tan(2.33))
        ])
        XCTAssert(scale.evaluate(sceneProps) == expectedMatrix)
        XCTAssert(scale.usesTime() == true)
    }
    
    func testEGTransformProperty() throws {
        let transform = EGTransformProperty()
        transform.checkIfStatic()
        XCTAssert(transform.isStatic == true)
        
        transform.translate.setTranslation(
            x: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .sin, child: EGConstant(12))),
            y: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .tan, child: EGConstant(8))),
            z: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: EGConstant(311)))
        )
        transform.checkIfStatic()
        XCTAssert(transform.isStatic == true)
        var transformationMatrix = transform.transformationMatrix(sceneProps)
        var expectedMatrix = matrix_float4x4(translation: [cos(sin(12)), cos(tan(8)), abs(sin(311))])
        XCTAssert(transformationMatrix == expectedMatrix)
        
        transform.translate.setTranslation(
            x: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .sin, child: EGConstant(1.12))),
            y: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .tan, child: EGConstant(88))),
            z: EGUnaryOp(type: .abs, child: EGUnaryOp(type: .sin, child: EGConstant(3)))
        )
        transform.checkIfStatic()
        XCTAssert(transform.isStatic == true)
        transformationMatrix = transform.transformationMatrix(sceneProps)
        expectedMatrix = matrix_float4x4(translation: [cos(sin(1.12)), cos(tan(88)), abs(sin(3))])
        XCTAssert(transformationMatrix == expectedMatrix)
    
        transform.rotate.setRotation(x: 1, y: 2, z: 3)
        transform.checkIfStatic()
        XCTAssert(transform.isStatic == true)
        expectedMatrix = matrix_float4x4(translation: [cos(sin(1.12)), cos(tan(88)), abs(sin(3))])
            * matrix_float4x4(rotation: [1, 2, 3])
        transformationMatrix = transform.transformationMatrix(sceneProps)
        XCTAssert(transformationMatrix == expectedMatrix)
        
        sceneProps.time = 122
        transform.scale.setScale(
            x: EGUnaryOp(type: .sin, child: EGTime()),
            y: EGUnaryOp(type: .cos, child: EGUnaryOp(type: .cos, child: EGTime())),
            z: EGUnaryOp(type: .sin, child: EGTime())
        )
        transform.checkIfStatic()
        XCTAssert(transform.isStatic == false)
        transformationMatrix = transform.transformationMatrix(sceneProps)
        expectedMatrix = matrix_float4x4(translation: [cos(sin(1.12)), cos(tan(88)), abs(sin(3))])
            * matrix_float4x4(rotation: [1, 2, 3])
            * matrix_float4x4(scale: [sin(sceneProps.time), cos(cos(sceneProps.time)), sin(sceneProps.time)])
        XCTAssert(transformationMatrix == expectedMatrix)
        
        sceneProps.time = 15885
        transformationMatrix = transform.transformationMatrix(sceneProps)
        expectedMatrix = matrix_float4x4(translation: [cos(sin(1.12)), cos(tan(88)), abs(sin(3))])
            * matrix_float4x4(rotation: [1, 2, 3])
            * matrix_float4x4(scale: [sin(sceneProps.time), cos(cos(sceneProps.time)), sin(sceneProps.time)])
        XCTAssert(transformationMatrix == expectedMatrix)
    }
}
